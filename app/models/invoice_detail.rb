class InvoiceDetail < ActiveRecord::Base
  belongs_to :invoice
  belongs_to :sign_product
  
  def self.make_from_line_item item
    attributes = {
      :sign_product_id => item.id,
      :qty => item.qty
    }
    self.new attributes
  end
  
end
