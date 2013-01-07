module MessagesHelper
  include ApplicationHelper

  def listing_label
    (can_delete? ? "Your" : "The") + " Listing"
  end
  
  def can_delete?
    (logged_in? and active_user == @message.user)
  end
end