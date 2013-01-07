#  add some promo codes

class AddPromoCode
  def self.add_promo name, val, options={}, start = Date.today, finish = (Date.today + 30)
    PromoCode.create :name => name, options[:type] => val, :start => start, :finish => finish 
  end

  def self.add_promo_pct name, val
    add_promo name, val, {:type => :discount_pct}
  end

  def self.add_promo_flat name, val
    add_promo name, val, {:type => :discount_flat}
  end

  def self.add_2
    self.add_promo_flat 'Fla5', 500
    self.add_promo_pct 'Pct10', 10
  end
  
end


