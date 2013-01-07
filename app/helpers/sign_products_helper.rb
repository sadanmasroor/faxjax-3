module SignProductsHelper
  def type_link(type_name, link_name=nil)
    link_name ||= type_name
    options = {:action => "list", :type => type_name}
    if current_page?(options)
      (strong do
        link_to_unless_current link_name, options
      end).html_safe
    else
      (link_to_unless_current link_name, options).html_safe
    end   
  end
  
  def checkout_row key, product
    td(:style=>"font-size: 10px;") do
      product.title_string
    end + td(:align=>"right") do
      input(:type=>"text", :id=>"#{key}", 
        :class=> "quantity", :style=>"text-align: right",
        :sixe=>"4", :maxlength=>"3", 
        :value=>product.qty, :name=>"qty_#{key}")
    end + td(:align=>"right") do
      product.price_alt
    end + td(:id=>"line_price_#{key}", :align=>"right") do
      product.line_price_alt
    end + td do
      link_to "Remove", :action => "remove_cart_item", :id => key
    end
  end
  
  #  builds the checkout table of line items for the order review page row by row
  def checkout_table cart
    rows=''
    count=1
    cart.sign_products.each do |key, product|
      rows << tr do
        checkout_row key, product
      end
    end
    rows
  end
  
  #  becomes the hidden fields in the form posted to paypal
  def paypal_hash(cart)
    result = {}
    count = 1
    cart.sign_products.each do |key, product|
      result["item_number_#{count}".to_sym] = product.id
      result["item_name_#{count}".to_sym] = product.title_string
      result["quantity_#{count}".to_sym] = product.qty
      result["amount_#{count}".to_sym] = product.price.to_f/100
      count += 1
    end
    
    #  handle possible promo discount
    result[:discount_amount_cart] = cart.discount_total.to_f/100 unless cart.discount_total.zero?
    
    
    result.merge({
      :upload => 1,
      :image_url => PAYPAL_IMAGE_URL,
      :no_shipping=>0, # customer is asked for shipping address
      :cmd=>"_cart",
      :business => PAYPAL_BUSINESS,
      # :custom => session.session_id,
      :custom => cart.invoice_nonce,
      :notify_url => PAYPAL_BASE_URL + "/sign_products/process_purchase",
      :return => PAYPAL_BASE_URL + "/sign_products/purchase_complete",
      :rm => 1,
      :cbt => "Return to Faxjax.com",
      :shipping_1 => cart.shipping_total.to_f/100
    }).extend(TagHelper::HashHelper)
  end
end
