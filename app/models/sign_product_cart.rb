require "json"

class SignProductCart
 # include Reloadable
  include CurrencyFormatter
  
  attr_accessor :sign_products, :promo_code, :affiliate_code, :invoice_nonce
  def initialize
    @current = 1      
    @affiliate_code = ''
    @sign_products = {} # why not a simple array?
    @invoice_nonce = ''
  end

  def add(sign_product)
    @sign_products[@current.to_s] = sign_product.extend(::LineItem)
    @current += 1
  end

  def remove(key)
    @sign_products.delete(key)
  end
  
  def shipping_total
    if @sign_products.empty?
      0
    else
      ShippingAmount.from_yaml.amount
    end
  end
  
  def shipping_total_alt
    dollar_str shipping_total
  end
  
  def tax_total
    0
  end
  
  def tax_total_alt
    dollar_str tax_total 
  end
  
  def items_total
    (@sign_products.values.inject(0) {|i,v| i+ v.line_price})    
  end
  
  def subtotal
    items_total - discount_total
  end
  
  def subtotal_alt
    dollar_str subtotal
  end
  
  def discount_total
    return 0 if @sign_products.empty?
    PromoCode.discount @promo_code, items_total
  end
  
  def discount_total_alt
    dollar_str discount_total
  end
  
  def total
    subtotal + tax_total + shipping_total # - discount_total
  end
  
  def total_alt
    dollar_str total
  end
  
  def items_array
    arry = []
    @sign_products.each do |k,v|
      h = v.to_hash
      h[:key]=k
      arry << h
    end
    arry
  end
  
  def count
    @sign_products.values.inject(0) {|i,v| i+v.qty}
  end
  
  def count_str
    "#{count} item" + (count > 1 ? 's' : '')
  end
  
  def to_hash
    {:items=>items_array,
      :total => total_alt,
      :discount => discount_total_alt,
      :shipping => shipping_total_alt,
      :subtotal => subtotal_alt,
      :count => count_str}
  end
  
  def to_json
    JSON.generate self.to_hash  # .to_json
  end
  
end
