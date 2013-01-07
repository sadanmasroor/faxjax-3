require "time"
require "pp"

class Invoice < ActiveRecord::Base
  has_many :invoice_details
  
  def unique_identity
    "#{self.id}|#{Time.now.utc.iso8601}"
  end
  
  def self.create_with_nonce(attributes={})
    this = self.create attributes
    NonceStore.create_with_model this, :unique_identity
    this
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
  
  def self.create_from_cart cart
    attributes = {
      :tax => cart.tax_total,
      :shipping => cart.shipping_total,
      :discount => cart.discount_total,
      :total => cart.total,
      :promo_code => cart.promo_code,
      :affiliate_code => cart.affiliate_code
    }
    this = self.create_with_nonce attributes
    cart.sign_products.each do |key, value|
      this.invoice_details << InvoiceDetail.make_from_line_item(value)
    end
    this
  end
  
  def update_from_cart cart
    attributes = {
      :tax => cart.tax_total,
      :shipping => cart.shipping_total,
      :discount => cart.discount_total,
      :total => cart.total,
      :promo_code => cart.promo_code,
      :affiliate_code => cart.affiliate_code
    }
    update_attributes attributes
    invoice_details.delete_all
    cart.sign_products.each do |key, value|
      self.invoice_details << InvoiceDetail.make_from_line_item(value)
    end
  end



  def update_from_paypal hash
    keymap = {
      :address_street => :street=,
      :address_city => :city=,
      :address_state => :state=,
      :address_zip => :zip=,
      :payer_email => :email=
    }
    keymap = keymap.stringify_keys
    hash.each do |key, value|
      if keymap.keys.include?(key)            
        self.send(keymap[key], value)
      else
        # puts "#{key} not found"
      end
    end
    first_n, last_n = hash["address_name"].split
    self.first_name = first_n
    self.last_name = last_n
    self.save
  end
  
  def create_signs
    signs = Sign.find_salable(invoice_details.inject(0) {|i,v| i+v.qty})
    @signs = []
    invoice_details.each do |detail|
      detail.qty.times do
        sign = signs.shift
        sign.sign_type = detail.sign_product.sign_type
        sign.sign_product_id = detail.sign_product_id
        # p sign.sign_product_id
        sign.save
        @signs << sign
      end
    end
    @signs
  end
  
  def send_mail
    signs = create_signs
    Notifier.deliver_faxjax_purchase_completion_notification self, signs
    Notifier.deliver_user_purchase_completion_notification self, signs
  end
end
