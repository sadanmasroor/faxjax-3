# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # rescue ::RuntimeError, :with => :render_404
  
  before_filter :check_permissions,
                :set_before_attributes

  after_filter  :set_referring_controller_action_and_id,
                :set_affiliate_code,
                :set_after_attributes

  helper_method :action_name, 
                :controller_name,
                :active_user,
                :logged_in,
                :logged_in?,
                :user?,
                :admin?

  

  #def render(options = nil, deprecated_status = nil, &block)
  #  set_after_attributes
    #super
 # end

  def error
    render :template => "error"
  end
  
  def permissions(type, *actions)
    @permissions = {} if @permissions.nil?
    @permissions[type] = actions
  end
  
  def titles(titles = {})
    @titles = titles
    @title = titles.stringify_keys[action_name] if !titles.nil?
  end
  
  def check_permissions
    if !user? and !@permissions.nil?
      if !@permissions[:user].nil?
        @permissions[:user].each do |action|
          if action.to_s == action_name.to_s && !admin?
            flash[:warning] = "You must be signed in."
            redirect_to_login
          end
        end
      end
    end
    if !admin? and !@permissions.nil?
      if !@permissions[:admin].nil?
        @permissions[:admin].each do |action|
          if action.to_s == action_name.to_s
            flash[:warning] = "You must be signed in as an administrator."
            redirect_to_login
          end
        end
      end
    end
  end

  def set_before_attributes
    @now = Time.now
    @root_category = Category.find(Category::ROOT_ID)
    @root_categories = Category.find(Category::ROOT_ID).children

    @videos = Video.find(:all)

    # Breadcrumbs
    @breadcrumbs = [];
    @added_breadcrumbs = [];
    @breadcrumbs << Breadcrumb.new('Home', 'home', 'index')
  end

  def add_crumb(breadcrumb)
    @added_breadcrumbs << breadcrumb if !breadcrumb.nil?
  end

  def set_after_attributes
    # Code modified by Bill to make the code works with Rails 3
    if @breadcrumbs
      @breadcrumbs.concat(@added_breadcrumbs) 
    else
      @breadcrumbs = [];
    end
    @breadcrumbs << Breadcrumb.new(@title, controller_name, action_name, params[:id]) if !@title.nil? && @no_title_breadcrumb.nil?
  end

  # register any possible affiliate code on incoming links
  def set_affiliate_code
    unless params[:ac].nil?
      aff_code = params[:ac] 
      session[:affiliate_code] = aff_code 
      Tracking.track_affiliate aff_code, request.remote_ip
      if request.nil?
        logger.info "no request"
      else
        logger.info request.remote_ip
      end
    end
  end

  def set_referring_controller_action_and_id
    unless controller_name == "home" and action_name == "sign_in"
      session[:referring_action] = action_name
      session[:referring_controller] = controller_name
      session[:referring_id] = params[:id]
      logger.info "REFERRING CONTROLLER #{session[:referring_controller]}"
    end
  end

  def reset_session
    session[:admin] = nil
    session[:user_id] = nil
    session[:user_first_name] = nil
    session[:user_last_name] = nil
    session[:cart] = nil
  end

  def login_user(user)
    reset_session
    if user != nil
      session[:user_id] = user.id
      session[:user_first_name] = user.first_name
      session[:user_last_name] = user.last_name
    end
  end

  def login_admin
    reset_session
    session[:admin] = true
  end

  def redirect_to_referer(options = nil)
    if (
      controller_name != session[:referring_controller] ||
      action_name != session[:referring_action] ||
      params[:id] != session[:referring_id]
      )
      options = {} if options.nil?
      options[:controller] = session[:referring_controller]
      options[:action] = session[:referring_action]
      options[:id] = session[:referring_id]
      
      redirect_to options
    else
      redirect_to :controller => "home"
    end
  end

  def redirect_to_home
    redirect_to :controller => "home"
  end

  def redirect_to_login(name = nil)
    redirect_to :controller => "home", :action => "sign_in", :name => !name.nil? ? name : nil
  end

  def logged_in
    logged_in?
  end
  def logged_in?
    user? || admin?
  end

  def user?
    !session[:user_id].nil?
  end

  def admin?
    session[:admin] == true
  end

  def active_user
    @active_user = User.find(session[:user_id]) unless session[:user_id].nil? or !@active_user.nil?
    @active_user
  end

  # Found Methods
  def paginate_collection(collection, options = {})
    default_options = {:per_page => 10, :page => 1}
    options = default_options.merge options
    pages = Paginator.new self, collection.size, options[:per_page], options[:page]
    first = pages.current.offset
    last = [first + options[:per_page], collection.size].min
    slice = collection[first...last]
    return [pages, slice]
  end

  def paginate_many_results(klass, options = {}, sql = nil)
    # 1: set variables
    page = options[:page].nil? ? 1 : options[:page].to_i
    per_page = options[:per_page].nil? ? 10 : options[:per_page].to_i
    order = options[:order]
    conditions = options[:conditions]
    offset = (page - 1) * per_page.to_i

    # 2: get record count
    if sql.nil?
      item_count = klass.count(:all, {:conditions => conditions, :limit => per_page, :order => order})
    else
      item_count = klass.count_by_sql(sql)
    end

# {:offset => offset, 

    # 3: create a Paginator, second var is # of all items on all pages
    pages = Paginator.new(self, item_count, per_page, page)

    p '------'
    p "page #{page}"
    p "item_count #{item_count}"
    p "sql #{sql}"
    p pages.current.number
    p params
    p '------'

    # 4: only find the requested subset of @items
    #    must merge the offset and limit into the current find_options
    if sql == nil
      slice = klass.find(:all, {:offset => offset, :conditions => conditions, :limit => per_page, :order => order})
    else
      slice = klass.find_by_sql(sql+" LIMIT "+offset.to_s+","+per_page.to_s)
    end
    
    return [pages, slice]
  end

  private
  def render_404(exception = nil)
    if exception
        logger.info "Rendering 404: #{exception.message}"
    end

    render :text => "We are sorry, but that sign could not be found", :status => 404 
    # :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end
  
    def listings
    Listing.find(:all, :conditions => ["category_id = ? AND expires_on > ? AND sign_code IS NOT NULL", self.id, Time.now-10.minutes])
  end
  
end


