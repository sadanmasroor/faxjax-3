class Contact < ActiveRecord::Base
  validates_presence_of :lname, :fname, :address_1, :city, :state, :postal_code, :phone_1, :email_1
  validates_uniqueness_of :email_1

  def generate_affiliate_code
    raise "Cannot generate affiliate_code if not a new record" if new_record?
    Base64.encode64('%04d' % self.id)[0..-4]
  end
  
  def become_affiliate
    self.promo_code = generate_affiliate_code
    save
    PromoCode.create :name => promo_code, :rebate_pct => 2
    Tracking.create_affiliate promo_code
    Notifier.deliver_affiliate_instructions email_1, promo_code
  end
end
