class Message < ActiveRecord::Base
  include ActionView::Helpers::UrlHelper	
  belongs_to :user

  validates_presence_of :from_email, :subject, :message, :user_id
  
  def read?
    !self.read_on.nil?
  end
  
  def deleted?
    not self.deleted_on.nil?
  end

  def from_user
    User.find(self.from_user_id)
  end

  def view_url controller
    controller.url_for :controller => 'messages', :action => 'read', :id => id
  end

  def self.create_with_nonce(attributes={})
    this_message = self.create attributes
    NonceStore.create_with_model this_message, :from_email
    this_message
  end

  def nonce
    NonceStore.find_by_foreign_model self
  end

  def self.find_by_nonce nonce
    nonce = NonceStore.find_by_value nonce
    unless nonce.nil?
      self.find nonce.foreign_id
    else
      nil
    end
  end

  def send_email url="http://www.faxjax.com"
    if valid?
      @mail = Notifier.listing_inquiry(user.email, subject, message, nonce.value, url)
      @mail.reply_to = self.from_email
      begin
        Notifier.deliver(@mail)
      rescue Errno::ECONNREFUSED => e
        logger.info "Message email failed delivery"
        logger.info "Exception was #{e.message}"
        return false
      end
    else
      return false
    end
    return true
  end

  protected

  def validate
    errors.add_on_empty(:user_id, "not found, please select a valid user.")
    # Profanity filters
    if ProfanityFilter.profane?(subject)
      errors.add(:subject, "cannot include profanity! (The word '#{ProfanityFilter.profane_word(subject).to_s.strip}' is not allowed)")
    end
    if ProfanityFilter.profane?(message)
      errors.add(:message, "cannot include profanity! (The word '#{ProfanityFilter.profane_word(message).to_s.strip}' is not allowed)")
    end
  end
end
