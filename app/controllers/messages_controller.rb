class MessagesController < ApplicationController

  prepend_before_filter {|c| 
    c.permissions :user, :list, :new, :send, :read, :view
    c.titles      :inbox => "Messages - Inbox",
                  :sent => "Messages - Sent",
                  :new => "New Message",
                  :read => "Read Message",
                  :reply => "Reply to Message",
                  :view => "Read Message"
  }

  def inbox
    @messages = active_user.messages
  end

  def sent
    @messages = active_user.sent_messages
  end

  def reply
    @message_controller = 'messages' if @message_controller.nil?
    @message_action = 'reply' if @message_action.nil?
    @message_id = params[:id] if @message_id.nil?
    begin
      @reply_message = Message.find(params[:id])
      @reply_user = @reply_message.from_user
    rescue
      flash[:warning] = "No message to reply to!"
      redirect_to :action => :inbox
    else
      if @reply_user.id == active_user.id
        flash[:warning] = "You cannot reply to yourself!"
        redirect_to :action => :inbox
      end
      new
    end
  end
  
  def new
    if params[:commit] == "Cancel"
      redirect_to :action => :inbox
      return
    end

    #@contacts = active_user.contacts
    #if @contacts.nil? or @contacts.empty?
    #  flash[:warning] = "You haven't sent or received messages from anyone yet."
    #end

    @message_controller = 'messages' if @message_controller.nil?
    @message_action = 'new' if @message_action.nil?
    
    @message = Message.new(params[:message])
    @message.from_user_id = active_user.id
    if !params[:user_name].nil?
      user = User.find(:first, :conditions=>["name = ?", params[:user_name]])
      if !user.nil?
        @message.user_id = user.id
      end
    end
    if request.post? and @message.save
      # Check if the recipient user is set to receive an email notification when
      # a message is sent to him.
      if !@message.user.nil? && !@message.user.user_prefs.nil? && @message.user.user_prefs.notify_on_message_received
        Notifier.deliver_inbox_notification(@message.user, 
                      active_user.name, 
                      @message.subject,
                      self.request).deliver if !@message.user.nil? && !@message.user.email.nil? # sends the email
      end
      
      flash[:notice] = "Message sent."
      redirect_to :action => 'sent', :id => @message.id
    end
  end

  def read
    @message_controller = 'messages' if @message_controller.nil?
    @message_action = 'reply' if @message_action.nil?
    @message_id = params[:id]

    @reply_message = Message.find(:first, :conditions => ["id = ? AND (user_id = ? OR from_user_id = ?)", params[:id], active_user.id, active_user.id])
    @reply_user = @reply_message.from_user
    
    if @reply_message.nil?
      flash[:warning] = "Message does not exist."
      redirect_to_referer
    end

    if @reply_message.user_id == active_user.id
      # Update the "updated_on" field so the message is "read"
      @reply_message.read_on = Time.now
      @reply_message.save
    end
  end

  # view by nonce
  def view
    nonce = params[:id]
    @message = Message.find_by_nonce nonce
    if @message.nil?
      redirect_with_flash 'index', "Message does not exist!" 
      return
    elsif @message.deleted? and flash[:notice].nil?
      redirect_with_flash "index", "Message was deleted"
      return
    elsif !logged_in?
      session[:view_message] = nonce
      redirect_with_flash 'sign_in', "You must be logged in to read messages." 
      return
    elsif @message.user != active_user and @message.from_user_id != active_user.id
      redirect_with_flash 'index', "You cannot read others' messages!"
      return
    end
    @listing = Listing.find @message.listing_id unless @message.listing_id.nil?
  end


  def delete
    message = Message.find(params[:id])
    if message.user == active_user
      message.deleted_on = Time.now
      message.save
      flash[:notice] = "Message deleted."
      redirect_to_referer
    end
  end
  
  private
  
  def redirect_with_flash action, message, flash_level = :warning
    flash[flash_level] = message
    redirect_to :controller => 'home', :action => action
  end
end
