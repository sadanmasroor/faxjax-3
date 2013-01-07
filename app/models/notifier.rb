class Notifier < ActionMailer::Base
  include HomeHelper
  include MessagesHelper
  include CurrencyFormatter

  FAXJAX = "\"Faxjax, Inc.\" <support@faxjax.com>"

  def inbox_notification(user, from_user_name, message_subject)
    recipients user.email_address_with_name
    from       FAXJAX
    subject    "New Faxjax message from #{from_user_name}"
    body       "user" => user, 
               "from_user_name" => from_user_name,
               "message_subject" => message_subject,
               "home_url" => make_link(request, '')
  end

  def listing_inquiry(to_email, mail_subject, mail_body, mail_nonce, mail_url)
    recipients [to_email]
    from FAXJAX

    subject mail_subject
    body "body" => mail_body, "url" => mail_url, "nonce" => mail_nonce
  end


  def welcome_notification(user)
    recipients user.email_address_with_name
    from       FAXJAX
    subject    "Welcome to Faxjax!"
    body       "user" => user
  end
  

  def forgot_password_notification(user, request)
    recipients user.email_address_with_name
    from       FAXJAX
    subject    "Faxjax Forgot Password"

    #  prepare the password rest link
    link = make_reset_link(request, user.gen_hashed_link)
    
    body "link" => link
  end

  def user_purchase_completion_notification(invoice, signs)
    # This should really accept a user object but to make things
    # simple for this round of development we'll use what PayPal
    # sends us back as it must be accurate anyways.
    recipients invoice.email
    from       FAXJAX
    subject    "Faxjax Sign Order Confirmation"
    body       "invoice" =>  invoice,
               "signs"  => signs
  end

  # Send the order to FJ fullfilment
  def faxjax_purchase_completion_notification(invoice, signs)
    # raise "purchase_complete |#{params.inspect}|"
    recipients FAXJAX
    from       FAXJAX
    subject    "Faxjax Sign Order"
    body       "invoice" => invoice,
               "signs"  => signs,
               "promo_code" => invoice.promo_code,
               "affiliate_code" => invoice.affiliate_code
  end
  
  def affiliate_instructions email, affiliate_code
    recipients email
    from FAXJAX
    subject    "Instuctions for becoming a Faxjax, Inc. affiliate"
    body       "affiliate_code" => affiliate_code
  end

  def feedback(frm,subjct,messge)
   @recipients = FAXJAX
   cc   from
   from FAXJAX
   subject    subjct
   body       messge
  

  end  

end
