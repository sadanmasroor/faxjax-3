require 'search_listings'

class QController < ApplicationController
  include SearchListings

  def index
    redirect_to :controller => 'home', :action => 'index'
  end


  def s
    code = params[:id]
    unless code =~ /^\d[A-Z0-9][A-Z0-9]{0,3}$/
      flash[:warning] = "Invalid sign code entered. Please retry you search."
      redirect_to :controller => 'home', :action => 'index'
    else
      code = params[:id]
      @title = "Search Results for sign code: #{code}"
      @listings = search_listings_for_code(code) do |listing|
        @listing = listing
        redirect_to :action => "show", :id => @listing.id
      end
    end
  end

  def show
    @listing = Listing.find(params[:id].to_s)
    if @listing.nil?
      flash[:warning] = "Invalid sign code entered. Please retru you search."
      redirect_to :controller => 'home', :action => 'index'
    else
      @title = @listing.name
      
      @category = Category.find(!@listing.category_id.nil? ? @listing.category_id : Category::ROOT_ID);
      # For the message reply form
      @reply_user = @listing.user
      @message_controller = 'messages' if @message_controller.nil?
      @message_action = 'new' if @message_action.nil?

      add_crumb(Breadcrumb.new("Listings", "listings", "list"))
      build_category_crumbs(@listing.category).each do |crumb|
        add_crumb(crumb)
      end

      # Increment the hit counter
      @listing.increment_hits if !admin? && (active_user.nil? || @listing.user_id != active_user.id)
      
    end
    
  end
  
  private
  
  

  def build_category_crumbs(parent_category)
    category_crumbs = []
    while(parent_category != nil && parent_category.id != Category::ROOT_ID)
      category_crumbs << Breadcrumb.new(parent_category.name, "listings", "list", parent_category.id)

      # Get parent so we don't repeat ourselves
      parent_parent_category = parent_category.parent

      # Try to set active root category to highlight category in side bar
      @active_root_category = parent_category if parent_parent_category.id == Category::ROOT_ID

      parent_category = parent_parent_category
    end
    category_crumbs.reverse
  end
  
end
