require 'RMagick'

class SignProductsController < ApplicationController
  

  prepend_before_filter {|c| 
    c.permissions :admin, :edit, :update, :new, :create, :manual_checkout
    c.titles      :list => "Create a Listing",
                  :index => "Create a Listing",
                  :edit => "Edit Sign Product",
                  :new => "Create a New Sign Product",
                  :create => "Create a New Sign Product",
                  :checkout => "Checkout",
                  :paypal_checkout => "Review your Purchase",
                  :purchase_complete => "Purchase Complete",
                  :manual_checkout => "Manual Checkout"
  }

  def index
    redirect_to :action => "list"
  end
  
  def list
    begin
      @sign_products = SignProduct.find(:all, :order => "sign_type, sign_duration DESC, title ASC", :conditions => "deleted != 1")
      if admin?
        @title = "Sign Products"
        render :template => "sign_products/list_admin"
        return
      else
        if !params[:type].nil?
          # Filter out sign products that don't match the submitted sign_type
          @sign_products.collect! {|x| x.sign_type == params[:type] ? x : nil}.compact!
        end
      end
      
    rescue Exception => e
      flash[:warning] = 'SignProducts list error: ' + e.message
      redirect_to :controller => 'home'
      return
    end
  end
  
  def remove_cart_item
    cart_remove params[:id]
    redirect_to :action => "paypal_checkout"
  end

  def remove_from_cart
    cart_remove params[:id]
    redirect_to_referer(:type => params[:type])
  end

  def clear_cart
    session[:cart] = nil
    redirect_to_referer(:type => params[:type])
  end
  
  def add_to_cart
    if !params[:id].nil?
      session[:cart] = SignProductCart.new if session[:cart].nil?
      cart = session[:cart]
      type = params[:type]
  
      sign_product = SignProduct.find(params[:id])
      if !sign_product.nil?
        cart.add(sign_product)
        flash[:notice] = "\"#{sign_product.title_string}\" added to cart"
        options = {}
        options[:action] = "list"
        if !type.nil? && !type.empty?
          options[:type] = type
        end
        redirect_to options
        return
      end
    end
    redirect_to :action => "list"
  end

  def paypal_fields
    @cart = session[:cart]
    render :layout => false
  end


  #  manual checkout page from admin? presumabky
  def checkout
    
  end

  #  ajax call for promo code
  def change_qty
    cart = session[:cart]

    product = cart.sign_products[params["key"]]
    product.qty = params["value"].to_i unless product.nil?
    @invoice = Invoice.find_by_nonce cart.invoice_nonce
    @invoice.update_from_cart cart


    render :text => cart.to_json, :content_type => "json"
  end
  


  def promo_code
    cart = session[:cart]
    promo_code = params[:promo_code]
    logger.info "Promo code #{promo_code}"
    cart.promo_code = promo_code
    @invoice = Invoice.find_by_nonce cart.invoice_nonce
    @invoice.update_from_cart cart

    render :text => cart.to_json, :content_type => "json"
  end

  # Checkout page prior to submitting to paypal paypal
  def paypal_checkout
    affiliate_code = session[:affiliate_code]
    cart = session[:cart]
    cart.affiliate_code = affiliate_code unless affiliate_code.nil?
    if cart.invoice_nonce.blank?
      @invoice = Invoice.create_from_cart cart
      cart.invoice_nonce = @invoice.nonce.value
      session[:cart] = cart
    else
      @invoice = Invoice.find_by_nonce cart.invoice_nonce
      @invoice.update_from_cart cart
    end
  end

  def purchase_complete
    cart = session[:cart]

    @invoice = Invoice.find_by_nonce cart.invoice_nonce
    unless @invoice.nil?
      @invoice.send_mail
    else
      logger.info "ERROR: could not find Invoice from nonce |#{cart.invoice_nonce}| "
    end
    session[:cart] = nil
  end
  
  def process_purchase
    begin
      time = Time.now.strftime('%Y%m%d-%H%M%S')
      logger.info "PROCESSING PURCHASE"
      # Logs all of the values returned by PayPal
      logger.info "Params from PayPal"
      params.sort.each  do |elem|
        logger.info "#{elem[0]}: #{elem[1]}"
      end
      logger.info " END of Params from PayPal"
      logger.info "--- BEGIN oarams.to_yaml ---- " + time
      logger.info params.to_yaml
      logger.info "---   END oarams.to_yaml ----"
      
      @invoice = Invoice.find_by_nonce params[:custom]
      unless @invoice.nil?
        result = @invoice.update_from_paypal params 
        unless result
          logger.info "Failed to save nonce id #{@nonce.id}"
          logger.info @invoice.errors.to_s
        else
          logger.info "Invoice updated from Nonce"
        end
      else
        logger.info "invoice from nonce |#{params[:custom]}| not found"
      end
    rescue Exception => e
      logger.info "--- EXCEPTION pmprocess_purchase @ " + time
      logger.info e.to_s
    end
    

    # # This should do something extra with the verify_sign field but for now we'll just
    # # make sure it exists. When the PayPal API is fully integrated with automatic verification
    # # it'll need to do accurate validation.
    # 
    # valid = true
    # error_msg = "ok"
    # # If the required fields aren't passed back then invalid request
    # if params[:address_name].nil? || params[:address_name].empty? ||
    #    params[:address_city].nil? || params[:address_city].empty? ||
    #    params[:address_street].nil? || params[:address_street].empty? ||
    #    params[:address_state].nil? || params[:address_state].empty? ||
    #    params[:address_zip].nil? || params[:address_zip].empty? ||
    #    params[:payer_email].nil? || params[:payer_email].empty?
    #    valid = false
    #    error_msg = "Shipping info or email address not specified."
    # end
    # 
    # # If the verify_sign param isn't passed back then invalid request
    # 
    # if params[:verify_sign].nil?
    #   valid = false 
    #   error_msg = "pay_pal verification incorrect #{params[:verify_sign]}"
    # end
    # 
    # if !valid
    #   logd error_msg
    #   logger.error error_msg
    #   if admin?
    #    flash[:warning] = "Error completing manual checkout. #{error_msg}"
    #    redirect_to :action => "manual_checkout"
    #   end
    #   logd "return from !valid"
    #   return
    # end
    # 
    # # Otherwise finish processing the purchase and clear the shopping cart
    # cart = session[:cart]
    # 
    # paypal = false
    # if cart.nil?
    #   paypal = true
    #   # This is probably a PayPal purchase notification so build up a cart manually
    #   begin
    #     cart = SignProductCart.new
    #     params.each_pair do |key,val|
    #       if key.to_s =~ /item_number/
    #         cart.add(SignProduct.find(val.to_i))
    #       end
    #     end
    #   rescue
    #     cart = nil
    #   end
    # end
    # 
    # # If it's still nil, just show an error message
    # if cart.nil?
    #   flash[:warning] = "Cart was empty."
    #   redirect_to :controller => "home"
    # end
    # 
    # 
    # # Acquire signs and assign them to the Faxjax vendor so they are taken out of the list of salable signs
    # # Also set their sign_product_id based on the shopping cart
    # signs = []
    # if cart.nil? || cart.sign_products.nil?
    #   logd "retuenwd cart.nil? || cart.sign_products.nil?"
    #   return
    # end
    # cart.sign_products.each_pair do |key, sign_product|
    #   sign = Sign.find_salable(1)[0]
    #   sign.update_attributes({
    #     :vendor_id => Vendor::FAXJAX_ID,
    #     :duration => sign_product.sign_duration,
    #     :sign_product_id => sign_product.id
    #   })
    #   # Need to update the 'type' differently due to reserved word in Rails / Ruby
    #   Sign.update_all("`type` = '#{sign_product.sign_type}'", "id = #{sign.id}")
    #   signs.push(Sign.find(sign.id))
    # end
    # 
    # 
    # logger.info("Notifying #{params[:payer_email]}")
    # 
    # # Send the notification email to Faxjax
    # promo_code = cart.promo_code
    # affiliate_code = cart.affiliate_code
    # # logd params.inspect
    # Notifier.deliver_faxjax_purchase_completion_notification(params, signs, promo_code, affiliate_code)
    # 
    # # Send the notification email to the user
    # Notifier.deliver_user_purchase_completion_notification(params, cart, signs)
    # 
    # # Track the affilate conversion if any
    # Tracking.track_affiliate_conversion affiliate_code unless affiliate_code.blank?
    # # Clear the cart
    # session[:cart] = nil
    # 
    # # If this was a paypal notification, render nothing and clear out the session's 
    # # cart by manually pulling the session and clearing it
    # if paypal == true
    #   if !params[:custom].nil?
    #     session = CGI::Session::ActiveRecordStore::Session.find_by_session_id(params[:custom])
    #     if session.nil || session.data.nil?
    #       logd "return from session.nil || session.data.nil?"
    #       return
    #     end
    #     session.data[:cart] = nil
    #     ActiveRecord::Base.connection.execute("UPDATE sessions SET data = '#{CGI::Session::ActiveRecordStore::Session.marshal(session.data)}', updated_at = '#{DateTime.now.strftime("%Y-%m-%d %I:%M:%S")}' WHERE `session_id` = '#{params[:custom]}'")
    #   end
    #   render :nothing => true
    # else
    #   redirect_to :action => "purchase_complete"
    # end
    # 
    render :nothing => true
  end


  def new
    @sign_product = SignProduct.new
  end

  def create
    if params[:commit] == "Cancel"
      redirect_to :action => "list"
      return
    end

    @sign_product = SignProduct.new(params[:sign_product])
    @sign_product.price_alt = params[:sign_product][:price_alt] if !params[:sign_product][:price_alt].nil?

    if request.post? and @sign_product.save
      process_photo(@sign_product, params[:photo]) if !params[:photo].nil? and !params[:photo].instance_of? String

      flash[:notice] = 'Sign Product was successfully created.'
      redirect_to :action => "list"
    else
      render :action => 'new'
    end
  end

  def process_photo(sign_product, photo_param)
    photo_data = photo_param.read
    return if sign_product.nil? or photo_param.nil? or photo_data.nil?
    begin
      large_dimensions = SignProduct::PhotoLargeDimensions
      large_suffix = SignProduct::PhotoLargeSuffix
      small_dimensions = SignProduct::PhotoSmallDimensions
      small_suffix = SignProduct::PhotoSmallSuffix
      photo_path = SignProduct::PhotoDirPath
      photo_format = "jpeg"
      filepath_format = "%s%d_%s.%s"
  
      # Delete existing photo set
      delete_photo(sign_product.id)
      
      # Write photo to file
      rnum = rand(10000000)
      filename = "#{RAILS_ROOT}/tmp/_#{rnum}"
      File.open(filename, "wb") { |f| f.write(photo_data)}
      
      # Resize and save to Large and Small
      resize_and_save_photo(filename, large_dimensions, sprintf(filepath_format, photo_path, sign_product.id, large_suffix, photo_format))
      resize_and_save_photo(filename, small_dimensions, sprintf(filepath_format, photo_path, sign_product.id, small_suffix, photo_format))
    ensure
      # Cleanup
      File.delete(filename)
    end
  end
  
  def resize_and_save_photo(source_filename, dimensions, target_filename)
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

  def delete_photo(sign_product_id = nil, num = nil)
    return false if sign_product_id.nil? or num.nil?
    files = Dir[SignProduct::PhotoDirPath+"*"+sign_product_id.to_s+"*"]
    files.each do |file|
      File.delete(file)
    end
  end

  def edit
    @sign_product = SignProduct.find(params[:id])
  end
  
  def update
    if params[:commit] == "Cancel"
      redirect_to :action => "list"
      return
    end

    if request.post?
      @sign_product = SignProduct.find(params[:id])

      if @sign_product.update_attributes(params[:sign_product])
        process_photo(@sign_product, params[:photo]) if !params[:photo].nil? and !params[:photo].instance_of? String
        
        flash[:notice] = 'Sign Product was successfully updated.'
        redirect_to :action => 'list'
      else
        render :action => 'edit', :id => @sign_product
      end
    end
  end

  def delete
    SignProduct.find(params[:id]).destroy
    flash[:notice] = 'Sign Product was successfully deleted.'
    redirect_to :action => 'index'
  end

  def manual_checkout
    
  end
  
  private
  def params_to_query_string params={}
    URI.encode("?" + params.collect {|k,v| "#{k}=#{v}"}.join("&"))
  end
  
  def cart_remove key
    logger.debug "ID: #{key} CART: #{session[:cart].sign_products.length}"
    if !key.nil? && !session[:cart].nil?
      cart = session[:cart] 
      cart.remove(key)
      flash[:notice] = "Item removed from cart"
    end
  end
  
  def testing?
    RAILS_ENV == 'test'
  end
  
  def logd msg
    logger.debug "DEBUG_TEST: " + msg if testing?
  end
  
  def raised msg
    logd "Raised #{msg}"
    raise msg if testing?
  end
end
