
class PidController < ApplicationController
  
  
  
  def index
    if params[:search]
          @pid = Pid.find_by_code(params[:search].to_s)
          @message_controller = 'messages' if @message_controller.nil?
          @message_action = 'new' if @message_action.nil?
    end  
  end
  
  def send_message
    @pid = Pid.find params[:message][:pid_id].to_i
    
    unless @pid.nil?
      message = Message.create_with_nonce params[:message]
      message.from_user_id = active_user.id if logged_in?
      message.save
      url = "#{request.protocol}#{request.host}" + (request.port.blank? ? '' : ":#{request.port}")
      
      if @pid.mail_user message, url
        flash[:notice] = "Your message has been sent to #{@pid.user.first_name + " " + @pid.user.last_name}!"
        redirect_to :controller => "pid", :action=>"index"
      else
        flash[:warning] = "The email was not sent. Please contact Faxjax, Inc. support."
        redirect_to :controller => "pid", :action=>"index"
      end
    end
  end
  
  def show
    @pid = Pid.find_by_code(params[:id].to_s)
    if @pid.blank?
      flash[:warning] = "Invalid code entered. Please retry you search."
      redirect_to :action => 'index'
    else
      @title = "Search Results for sign code: #{@pid.code}"
      render 'show'
    end
   
  end
  
  def activate
    if !logged_in
        redirect_to_login
        session[:activating_pid] = true
        session[:activating_pid_code] = params[:code]
        session[:activating_pid_key1] = params[:key1]
        session[:activating_pid_key2] = params[:key2]
        session[:activating_pid_key3] = params[:key3]
        session[:activating_pid_key4] = params[:key4]
        flash[:info] = "Please <a href=\"#{url_for :controller => 'home', :action => 'sign_in'}\">sign in</a> or <a href=\"#{url_for :controller => 'users', :action => 'new'}\">create an account</a> before activating."
   else
     render 'activate'
       
   end
  
  end
  
  
  def activated
    @pid = Pid.find_by_code(params[:code].to_s)
    
    if @pid.blank?
      flash[:warning] = "Invalid code entered!"
      redirect_to :action => "activate"
    else
        key = params[:key1] + params[:key2] + params[:key3] + params[:key4]
        
        if @pid.key.gsub(/[-\s+]/,"") == key.to_s.gsub(/[-\s+]/,"") 
             @pid.user_id = active_user.id
             @pid.save
             @user = User.find(@pid.user_id)
             @user.update_attributes(:address => params[:address],:address2 => params[:address2],:city => params[:city],:state => params[:user][:state],:zip => params[:zip])
             @user.save(:validate => false)
             flash[:notice] = "Successfully activated the code"
             redirect_to :action => "activate"
             
          else
            flash[:warning] = "The key to activate the code is invalid"
            render "activate" 
        
        end
        
      
    end   
  end  

end
