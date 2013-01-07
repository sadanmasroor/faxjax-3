class UsersController < ApplicationController

  

  before_filter :add_users_crumb, :except => [:index, :list]

  prepend_before_filter {|c| 
    c.permissions :user, :edit, :update
    c.permissions :admin, :index, :destroy, :list, :show
    c.titles      :new  => "Create a New Account",
                  :create => "Create a New Account",
                  :edit => "Your Account",
                  :update => "Your Account",
                  :list => "Users",
                  :index => "Users",
                  :show => "User Details"
  }

  def add_users_crumb
    add_crumb(Breadcrumb.new(@titles[:index], "users", "list")) if admin?
  end
  
  def index
    list
    render :action => 'list'
  end

  def list
    @user_pages, @users = paginate_many_results User, {:page => params[:page], :per_page => !params[:per_page].nil? ? params[:per_page] : 10, :order => "last_name ASC"}
  end

  def show
    @user = User.find(params[:id])
    @listing_pages, @listings = paginate_many_results Listing, {:page => params[:page], :per_page => !params[:per_page].nil? ? params[:per_page] : 100}, "SELECT * FROM listings WHERE user_id = #{@user.id}" 
  end

  def new
    @title = "New User" if admin?
    @user = User.new
    if !session[:entered_name].nil?
      # If the user entered a name in the login and is now
      # registering a new user, fill in the name for them
      # as a courtesy.
      @user.name = session[:entered_name]
      session[:entered_name] = nil
    end
  end

  def create
    
    @title = "New User" if admin?
    if params[:commit] == "Cancel"
      redirect_to_home
      return
    end

    @user = User.new(params[:user])

    @user_prefs = UserPrefs.new(params[:user_prefs])
    @user_prefs.user_id = @user.id

    if request.post? and @user.save
      # Update any user prefs (like promo email flag)
      @user_prefs.save

      # Send the welcome email
      begin
        Notifier.deliver_welcome_notification(@user) if !@user.email.nil? # sends the email
        flash[:info] = 'A Welcome Email has been sent to your email address.'
      rescue Exception => e
        flash[:warning] = 'Email not sent: ' + e.message
        redirect_to :controller => 'home'
        return
      end
      
      
      # If admin is creating this user then return to the list page without logging in, otherwise log the user in and send to homepage
      if admin?
        flash[:notice] = "User created."
        redirect_to :action => "list"
        return
      else
        # Log the user in
        login_user(@user)
      end
      
      # If the user was trying to activate a sign send them to the
      # sign activate page with fields already filled in
      if !session[:activating_sign].nil?
        flash[:notice] = "Thank you for registering! You may continue activating your sign."
        redirect_to :controller => "signs", :action => "activate"
      elsif !session[:purchasing_signs].nil?
        flash[:notice] = "Thank you for registering! You may continue your purchase."
        redirect_to :controller => "sign_products", :action => "checkout"
      else
        session[:show_welcome_message] = true
        redirect_to :controller => "home"
      end
    else
      render :action => 'new'
    end
  end

  def edit
    if admin?
      @title = "Edit User"
      @user = User.find(params[:id])
    else
      @user = active_user
    end
    session[:entered_email] = @user.email
  end
 
  def update
    if admin?
      # Only the admin can update other users
      @title = "Edit User"
      @user = User.find(params[:id])
    else
      @user = active_user
    end

    if request.post?
      if params[:commit] == "Cancel"
        redirect_to_home
        return
      end

      #  for update purposes, make the passwords match
      @user.password_confirmation = @user.password
      errors = nil
      
      # Update the password if they pass one in
      # if !params[:passwd].nil? && !params[:passwd].empty?
      #   if params[:passwd] != params[:passwd_confirmation]
      #     errors = "Passwords do not match."
      #   else
      #     @user.update_attributes({:password => params[:passwd], :password_confirmation => params[:passwd_confirmation]})
      #   end
      # end

      # Update the rest of the attributes
      if errors.nil?
        params[:user].each do |k,v|
          puts k+" : "+v
        end
        if @user.update_attributes(params[:user])
          # Update any user prefs (like promo email flag)
          @user_prefs = UserPrefs.find_by_user_id(@user.id)
          if @user_prefs.nil?
            @user_prefs = UserPrefs.new
            @user_prefs.user_id = @user.id
          end
          @user_prefs.update_attributes(params[:user_prefs])
          
          flash[:notice] = "Your account has been updated."
          redirect_to :action => 'edit', :id => @user.id
        else
          render :action => 'edit'
        end
      else
        flash[:warning] = errors
        redirect_to :action => 'edit', :id => @user.id
      end
    end
  end

  def destroy
    User.find(params[:id]).destroy
    redirect_to :action => 'index'
  end
end
