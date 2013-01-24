require 'RMagick'
require "#{Rails.root.join("app","models","field.rb").to_s}"

class BasicListingsController < ApplicationController
  include ActionView::Helpers::TextHelper


  prepend_before_filter do |c| 
    c.permissions :user, :add, :delete, :edit, :save, :update
    c.titles      :add => "Add a Basic Listing",
                  :save => "Add a Basic Listing",
                  :add_photos => "Add a Basic Listing",
                  :update_photos => "Edit Your Listing"
  end

    def show
      begin
        @listing = BasicListing.find(params[:id]) if !params[:id].nil?
      rescue
        flash[:warning] = "(Exc) Listing not found!"
        redirect_to :action => "error", :id => nil
      else
        if @listing.nil?
          flash[:warning] = "(NIL)Listing not found!"
          redirect_to :action => "error", :id => nil
        else
          @title = @listing.name
          @category = Category.find(!@listing.category_id.nil? ? @listing.category_id : Category::ROOT_ID);
          # For the message reply form
          # @reply_user = @listing.user
          @message_controller = 'messages' if @message_controller.nil?
          @message_action = 'new' if @message_action.nil?

          add_crumb(Breadcrumb.new("Listings", 'listings', "list"))
          build_category_crumbs(@listing.category).each do |crumb|
            add_crumb(crumb)
          end

          # Increment the hit counter
          @listing.increment_hits if !admin? && (active_user.nil? || @listing.user_id != active_user.id)
        end
      end
    end

    def send_message
      @listing = Listing.find params[:message][:listing_id].to_i
      # <%= @host_and_port %>
      unless @listing.nil?
        message = Message.create_with_nonce params[:message]
        message.from_user_id = active_user.id if logged_in?
        message.save
        url = "#{request.protocol}#{request.host}" + (request.port.blank? ? '' : ":#{request.port}")
        # flash[:info] = url
        if @listing.mail_user message, url
          flash[:notice] = 'Your message has been sent!'
          redirect_to :controller => "listings", :action=>"show", :id => @listing.id
        else
          flash[:warning] = "The email was not sent. Please contact Faxjax, Inc. support."
          redirect_to :controller => "listings", :action=>"show", :id => @listing.id
        end
      end
    end

    def add
      add_step1
    end

    def add_step1
      if request.post?
        # Handle cancel button
        if params[:commit] == "Cancel"
          redirect_to :controller => "home"
          return
        else
          add_step2
          return
        end
      end

      render :action => "add_step1"
    end

    # ADD STEP 2
    def add_step2

      # Handle cancel button
      if params[:commit] == "Cancel"
        redirect_to :controller => "home"
        return
      end

      # Get the category if a category_id is passed in
      @category = Category.find(params[:category_id]) if !params[:category_id].nil?

      # If they didn't submit a category we need to send them back
      if @category.nil?
        flash[:warning] = "Please select a category."
        redirect_to :action => "add", :category_id => params[:category_id]
        return
      end

      if !@category.nil? and !@category.allow_listings
        flash[:warning] = "That category does not allow listings."
        redirect_to_referer
        return
      end


      # Set initial values on the Listing based on passed in parameters ( id, etc.)
      @listing = BasicListing.new
      @listing.category_id = params[:category_id]

      render :action => "add_step2"
    end

    # SAVE
    def update
      @title = "Edit Your Listing"
      add_crumb(Breadcrumb.new("Your Listings", controller_name, "list", "yours"))
      save
    end

    def save
      if request.post?

        @listing = Listing.new(params[:listing])
        @listing.description = strip_tags(@listing.description)
        @listing.user_id = active_user.id if !admin?
        @listing.expires_on = Time.now + 180.days # FIXME 

        # Get category
        @category = @listing.category

        @listing.price_alt = params[:listing][:price_alt] if !params[:listing][:price_alt].nil?

        # Get the extra field values
        listing_fields = {}
        # Get all the positive fields first (for checkbox handling)
        params.each do |key, value|
          if key =~ /^field_/
            listing_fields[key.slice("field_".length, key.length)] = value
          end
        end
        # Loop through again and get the negative fields (for checkbox handling)
        params.each do |key, value|
          if key =~ /^_field_/
            new_key = key.slice("_field_".length, key.length)
            listing_fields[new_key] = value if listing_fields[new_key].nil? 
          end
        end

        if !params[:listing][:id].nil? && !params[:listing][:id].empty?
          # Handle cancel button
          if params[:commit] == "Cancel"
            redirect_to :action => "list", :id => "yours"
            return
          end

          # Update
          @listing = Listing.find(params[:listing][:id])

          # Call the validate method so any errors get added
          # This must go before adding any errors to the object as it
          # first clears out all errors I guess.
          @listing.valid?

          # Loop through the passed in fields to check for required,
          # max length, etc.
          listing_fields.each do |field_id, value|
            field = Field.find(field_id)
            if !field.nil?
              if field.required && (value.nil? || value.empty?)
                @listing.errors.add_to_base("#{field.name} can't be blank")
              end
              if !field.maximum.nil? && (!value.nil? && !value.empty? && value.length > field.maximum)
                @listing.errors.add_to_base("#{field.name} must contain less than #{field.maximum} characters")
              end
            end
          end

          # If the listing doesn't belong to the active_user and the user isn't an admin redirect them and error
          if !admin? && @listing.user_id != active_user.id
            flash[:warning] = "Listing not found."
            redirect_to_referer
            return
          end


          @listing.price_alt = params[:listing][:price_alt] if !params[:listing][:price_alt].nil?
          listing_params = params[:listing]

          listing_params[:price] = @listing.price

          # Make sure the description has no HTML
          listing_params[:description] = strip_tags(listing_params[:description])

          listing_params[:expires_on] = @listing.expires_on

          # If there are no errors and the listing updates properly then also update fields
          if @listing.errors.length == 0 && @listing.update_attributes(listing_params)
            # Also update the category specific  fields
            @listing.update_fields(listing_fields)

            # If "Update photos" was checked then send them to the next page
            if params[:update_photos]
              flash[:notice] = "Listing updated, now go ahead and update your photos."
              redirect_to :action => "update_photos", :id => @listing.id
            else
              flash[:notice] = "Listing successfully updated."
              redirect_to :action => "show", :id => @listing.id
            end
          else
            render :action => "add_step2"
          end
        else
          # Handle cancel button
          if params[:commit] == "Cancel"
            redirect_to_referer
            return
          end

          # Call the validate method so any errors get added
          # This must go before adding any errors to the object as it
          # first clears out all errors I guess.
          @listing.valid?

          # Loop through the passed in fields to check for required,
          # max length, etc.
          listing_fields.each do |field_id, value|
            field = Field.find(field_id)
            if !field.nil?
              if field.required && (value.nil? || value.empty?)
                @listing.errors.add_to_base("#{field.name} can't be blank")
              end
              if !field.maximum.nil? && (!value.nil? && !value.empty? && value.length > field.maximum)
                @listing.errors.add_to_base("#{field.name} must contain less than #{field.maximum} characters")
              end
            end
          end

          # Save
          @listing.sign_code = ''
          if @listing.errors.empty? && @listing.save
            # Also save the category specific fields
            @listing.save_fields(listing_fields)

            # If "Add photos" was checked then send them to the next page
            if params[:add_photos]
              flash[:notice] = "Listing successfully added, now go ahead and add some photos."
              redirect_to :action => "add_photos", :id => @listing.id
            else
              flash[:notice] = "Listing successfully added to "+@listing.category.name+" category."
              redirect_to :action => "show", :id => @listing.id
            end
          else
            render :action => "add_step2"
          end
        end
      else
        redirect_to_referer
      end
    end

    # DELETE PHOTOS
    def delete_photos
      if request.post?
        if !params[:delete_photo1].nil?
          delete_photo_set(params[:id], 1)
        end
        if !params[:delete_photo2].nil?
          delete_photo_set(params[:id], 2)
        end
        if !params[:delete_photo3].nil?
          delete_photo_set(params[:id], 3)
        end
        if !params[:delete_photo4].nil?
          delete_photo_set(params[:id], 4)
        end
      end
    end

    # ADD PHOTOS
    def add_photos
      @listing = Listing.find(params[:id])
      if !admin? && @listing.user_id != active_user.id
        flash[:warning] = "Listing not found."
        redirect_to_referer
      end

      if request.post?
        if params[:commit] == "Cancel"
          redirect_to :action => 'show', :id => params[:id]
          return
        end

        errors = ''
        begin
          process_photo(@listing, params[:photo1].read, 1) if !params[:photo1].nil? and !params[:photo1].instance_of? String
        rescue 
          errors += "Bad photo format in #{params[:photo1].original_filename}. Accepted file types are JPG, BMP and GIF.<br/>"
        end
        begin
          process_photo(@listing, params[:photo2].read, 2) if !params[:photo2].nil? and !params[:photo2].instance_of? String
        rescue
          errors += "Bad photo format in #{params[:photo2].original_filename}. Accepted file types are JPG, BMP and GIF.<br/>"
        end
        begin
          process_photo(@listing, params[:photo3].read, 3) if !params[:photo3].nil? and !params[:photo3].instance_of? String
        rescue 
          errors += "Bad photo format in #{params[:photo3].original_filename}. Accepted file types are JPG, BMP and GIF.<br/>"
        end
        begin
          process_photo(@listing, params[:photo4].read, 4) if !params[:photo4].nil? and !params[:photo4].instance_of? String
        rescue 
          errors += "Bad photo format in #{params[:photo4].original_filename}. Accepted file types are JPG, BMP and GIF.<br/>"
        end
        if errors.length > 0
          flash[:warning] = errors  
          if @updating
            redirect_to :action => "update_photos", :id => params[:id]
          else
            redirect_to :action => "add_photos", :id => params[:id]
          end
        else
          if @updating
            flash[:notice] = "Photos updated."
          else
            flash[:notice] = "Photos successfully added to listing."
          end
          redirect_to :action => "show", :id => params[:id]
        end
      end
    end

    # CANCEL
    def cancel
      begin
        listing = Listing.find(params[:id])
        listing.cancel
      rescue
        flash[:warning] = "Could not cancel listing. Has it already been canceled?"
      end
      redirect_to_referer
    end

    # SHOW LARGE PHOTO
  def show_large_photo
    @listing = Listing.find(params[:id])
    render :layout => "photo_popup"
  end


    private

    def build_category_crumbs(parent_category)
      category_crumbs = []
      while(parent_category != nil && parent_category.id != Category::ROOT_ID)
        category_crumbs << Breadcrumb.new(parent_category.name, "listings", "list", parent_category.id)
        logger.debug 'BREADCRUMB:' + category_crumbs[-1].inspect 

        # Get parent so we don't repeat ourselves
        parent_parent_category = parent_category.parent

        # Try to set active root category to highlight category in side bar
        @active_root_category = parent_category if parent_parent_category.id == Category::ROOT_ID

        parent_category = parent_parent_category
      end
      category_crumbs.reverse
    end

    def process_photo(listing = nil, photo_data = nil, num = nil)
      return if listing.nil? or photo_data.nil?
      begin
        large_dimensions = Listing::PhotoLargeDimensions
        large_suffix = Listing::PhotoLargeSuffix
        medium_dimensions = Listing::PhotoMediumDimensions
        medium_suffix = Listing::PhotoMediumSuffix
        small_dimensions = Listing::PhotoSmallDimensions
        small_suffix = Listing::PhotoSmallSuffix
        photo_path = Listing::PhotoDirPath
        photo_format = "jpeg"
        filepath_format = "%s%d_%d_%s.%s"

        # Delete existing photo set
        delete_photo_set(listing.id, num)

        # Write photo to file
        rnum = rand(10000000)
        filename = "#{RAILS_ROOT}/tmp/_#{rnum}"
        File.open(filename, "wb") { |f| f.write(photo_data)}

        # Resize and save to Large, Medium and Small
        resize_and_save_photo_set(filename, large_dimensions, sprintf(filepath_format, photo_path, listing.id, num, large_suffix, photo_format))
        resize_and_save_photo_set(filename, medium_dimensions, sprintf(filepath_format, photo_path, listing.id, num, medium_suffix, photo_format))
        resize_and_save_photo_set(filename, small_dimensions, sprintf(filepath_format, photo_path, listing.id, num, small_suffix, photo_format))
      ensure
        # Cleanup
        File.delete(filename)
      end
    end

    def resize_and_save_photo_set(source_filename, dimensions, target_filename)
      # Create RMagick Photo
      photo = Magick::Image.read(source_filename).first

      photo = photo.change_geometry(dimensions) { |cols, rows, pht|
        pht.resize!(cols,rows)
      }

      dimensions_w = dimensions.split("x").first.to_i
      dimensions_h = dimensions.split("x").last.to_i
      w = photo.columns
      h = photo.rows
      pixels = photo.export_pixels(0,0,w,h, "RGB")

      photo = Magick::Image.new(dimensions_w,dimensions_h)
      photo.import_pixels(((dimensions_w-w)/2),((dimensions_h-h)/2),w,h,"RGB",pixels)

      photo.write(target_filename) { |photo_info|
        photo_info.quality = 60
      }
    end

    def delete_photo_set(listing_id = nil, num = nil)
      return false if listing_id.nil? or num.nil?
      files = Dir[Listing::PhotoDirPath+"*"+listing_id.to_s+"_"+num.to_s+"*"]
      files.each do |file|
        File.delete(file)
      end
    end


end
