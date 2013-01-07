#  extends sing product with qty and line item price
module LineItem
  def qty= val
    @qty = val unless val < 1
  end
  
  def qty
    @qty ||= 1
  end
  
  def line_price
    (price.nil? ? 0 : price) * qty
  end
  
  def line_price_alt
    dollar_str line_price
  end
  
  def to_hash
    {:qty=>qty, :line_price=>line_price_alt}
  end
end