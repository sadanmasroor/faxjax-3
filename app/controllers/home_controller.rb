class HomeController < ApplicationController

  prepend_before_filter {|c| 
    c.titles      :sign_in             => "Sign In",
                  :where_to_buy_signs  => "Where to Buy Signs", # REMOVEME this page soesn't exist
                  :forgot_password     => "Forgot Your Password?",
                  :reset               => "Reset Your Password",
                  :tos                 => "Terms & Conditions",
                  :privacy             => "Privacy Policy",
                  :about               => "About Faxjax",
		   :how_it_works               => "How It Works"
  }

  def index
    @title = "Welcome to Faxjax" if !admin?
    @title = "Faxjax Administration" if admin?
    @featured = Listing.find(:all,:conditions => ["featured=?",true],:limit=>5, :order => 'updated_on DESC')
    if session[:show_welcome_message] == true
      # @todo make this use a UserPreferences object that stores all preferences 
      # in a DB table
      @show_welcome = true
      session[:show_welcome_message] = nil
    end
  end

  def sign_in
    if request.post?
      if !params[:name].nil? && params[:name].downcase == "admin"
        # This is an admin login
        @application_config = ApplicationConfig.get_config
        if params[:password] == @application_config.admin_password
          login_admin
          redirect_to_home
        else
          reset_session
          flash[:login_notice] = "There is no account with that username and password. If you aren't yet a member please <a href=\"#{url_for :controller => 'users', :action => 'new'}\">create an account</a>."
          redirect_to_login
        end
      else
        # This is a regular user login
        user = User.login(params[:name], params[:password])
        if !user.nil?
          login_user(user)
          if !session[:activating_sign].nil?
            flash[:notice] = "Thank you for signing in! You may continue activating your sign."
            redirect_to :controller => "signs", :action => "activate"
          elsif !session[:purchasing_signs].nil?
            flash[:notice] = "Thank you for signing in! You may continue your purchase."
            redirect_to :controller => "sign_products", :action => "checkout"
          elsif !session[:view_message].nil?
            redirect_to :controller => 'messages', :action => 'view', :id => session[:view_message]
          else
            if ![controller_name, "users"].include?(session[:referring_controller])
              redirect_to_referer
            else
              redirect_to_home
            end
          end
        else
          reset_session
          session[:entered_name] = params[:name]
          flash[:login_notice] = "There is no account with that username and password. If you aren't yet a member please <a href=\"#{url_for :controller => 'users', :action => 'new'}\">create an account</a>."
          redirect_to :controller => "home", :action => "sign_in", :name => params[:name]
        end
      end
    end
  end

  def sign_out
    reset_session
    redirect_to_home
  end

  def forgot_password
    @name = session[:entered_name]
    @email = session[:entered_email]
    session[:entered_email] = nil
    session[:entered_name] = nil
    if request.post?
      if !params[:name].nil? && !params[:name].empty?
        @user = User.find_by_name(params[:name])
      elsif !params[:email].nil? && !params[:email].empty?
        @user = User.find_by_email(params[:email])
      else
        flash[:warning] = "You must enter a username or password."
        redirect_to :action => :forgot_password
      end

      if @user.nil?
        if !params[:name].nil? && !params[:name].empty?
          flash[:warning] = "Couldn't find an account with that username."
          session[:entered_name] = params[:name]
        elsif !params[:email].nil? && !params[:email].empty?
          flash[:warning] = "Couldn't find an account with that email address."
          session[:entered_email] = params[:email]
        end
        redirect_to :action => :forgot_password
      else
        begin
          Notifier.deliver_forgot_password_notification(@user, self.request)
	 
	  
          flash[:info] = "An email with a link to reset your password has been sent to the email address associated with your account which you should receive in a few minutes. Please visit that link after you receive this email."
        rescue Exception => e
	 
	  
          flash[:warning] = 'Email failed: ' + e.message
        end
        redirect_to :action => :index
      end
    end
  end

  # Resetting a user's password via link sent by email
  def reset
    @user = User.find_by_hashed_link params[:id]

    if @user.nil?
      flash[:error] = "This link has expired. Try sending another request via 'Forgot your password'"
      redirect_to :action => :forgot_password
    else
      if request.post?
        @user.password = params[:user][:password]
        @user.password_confirmation = params[:user][:password_confirmation]
        if @user.reset_password
          flash[:notice] = "Your password has been reset. You can now login."
          redirect_to :action => :sign_in
        end
      else
        @user.password = nil
        @user.password_confirmation = nil
      end
    end
  end
  
  #  REMOVEME - page doesn't yet exist
  def where_to_buy_signs
    
  end

  def tos
    
  end

  def privacy
    
  end

  def about
    
  end
  
  def how_it_works
  end
  
  def video1
  end
  
    def video2
    end
    
      def video3
      end
      
   def sendmail
      from = params[:email][:from]
	  subject = params[:email][:subject]
    message = params[:email][:message]
	  
      Notifier.deliver_feedback(from,subject,message)
       flash[:notice] = "Your feedback has been sent."
     redirect_to :controller => "home", :action => "index"
   end
   
  def feedback
	  #~ redirect_to :controller => "home", :action => "indx"
      #render :file => 'app\views\home\indx.rhtml'
   end

def company1
end

def company2
end

def home
end


 
end
