class BecomeAnAffiliateController < ApplicationController

  prepend_before_filter {|c| 
    c.titles :index => "Become An Affiliate of Faxjax, Inc.",
			 :thank_you => "Thank You for Requesting To Become an Affiliate."
  }

  def index
    @contact = Contact.new
  end

  def create
    logger.info "contact params"
    logger.info params[:contact].inspect
    @contact = Contact.new(params[:contact])
    if @contact.save
      @contact.become_affiliate
  		flash[:notice] = "Thank you for signing up to be an Affiliate of Faxjax, Inc. An email has been sent to you with instructions on adding you unique link to your website."
      redirect_to :action => 'thank_you'
    else
      render :action => 'index'
    end
  end


  def thank_you 
  end
  
end
