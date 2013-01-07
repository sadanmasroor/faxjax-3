class SignLot < ActiveRecord::Base
  has_and_belongs_to_many :signs, :join_table => :sign_lots_signs
  belongs_to :order
  belongs_to :sign_product
  before_destroy :reset_signs_and_clear_join_table

  validates_presence_of   :sign_product_id, :quantity, :price, :price_alt
  validates_numericality_of :quantity, :price

  attr_accessor :price_alt
  
  def self.new_from_template(id)
    if !id.nil?
      template = self.find(id)
      sign_lot = SignLot.new(:sign_product_id   => template.sign_product_id,
                             :price         => template.price,
                             :quantity      => template.quantity)
      sign_lot
    end
  end

  def self.find_templates
    self.find(:all, :conditions => "order_id IS NULL")
  end

  def price_alt=(value)
    # Strip the price of non-numeric chars (except for periods)
    self.price = (value.gsub(/[^\.\d]/,'').to_f * 100).to_i
  end

  def price_alt
    return nil if price == 0
    dollars, cents = self.price.divmod(100)
    dollars = dollars.to_s.reverse
    count = 1
    new_dollars = ''
    dollars_a = dollars.split(//)
    dollars_a.each do |char|
      new_dollars += char
      new_dollars += "," if count % 3 == 0 && count != dollars_a.length
      count += 1
    end
    sprintf("$%s.%02d", new_dollars.reverse!, cents)
  end

  def add_signs(signs)
    if !signs.nil? && signs.length > 0
      signs.each {|sign| self.signs << sign}
      self.save
      
      # #sql = 'INSERT INTO sign_lots_signs (`sign_id`, `sign_lot_id`, `id`) VALUES '
      # sql = 'INSERT INTO sign_lots_signs (`sign_id`, `sign_lot_id`) VALUES '
      # signs.each do |sign|
      #   sql += "(#{sign.id},#{self.id}),"
      #   #sql += "(#{sign.id},#{self.id},#{sign.id}),"
      # end
      # sql = sql.slice(0, sql.length-1) #remove the last comma
      # ActiveRecord::Base.connection.execute(sql)
    end
  end
  
  def reset_signs_and_clear_join_table
    logger.debug("Resetting signs")
    vendor_id = self.order.vendor_id if !self.order.nil?
    if !vendor_id.nil?
      ids = []
      self.signs.each do |sign|
        # Need to use sign_id here since the sign is created from a join table and the id is the join table id
        ids << sign.sign_id if sign.vendor_id == vendor_id
      end
      logger.debug("Resetting #{!ids.nil? ? ids.length.to_s : 0.to_s} signs")
      Sign.reset(ids)
    end
    logger.debug("Clearing join table")
    sql = "DELETE FROM sign_lots_signs WHERE sign_lot_id = #{self.id}"
    ActiveRecord::Base.connection.execute(sql)
    #return false
  end

  def to_csv(spid_to_sp)
    sign_product = spid_to_sp[self.sign_product_id]
    sign_type = ""
    sign_duration = ""
    sign_type = sign_product.sign_type unless sign_product.nil?
    sign_duration = sign_product.sign_duration unless sign_product.nil?
    
    csv_string = FasterCSV.generate(:force_quotes => true) do |csv|
      csv << [ "SIGN LOT"]
      csv << [
        "ID", "Order ID", "Sign Product ID", "Sign Type", "Sign Duration", "Quantity", "Price"
      ]
      csv << [
        self.id, self.order_id, self.sign_product_id, sign_type, sign_duration, self.quantity, self.price_alt
      ]
      csv << []
    end
    if !csv_string.nil?
      csv = Sign.array_to_csv(self.signs, self.order.vendor.name)
      if !csv.nil? 
        csv_string += csv
      end
    end
    csv_string
  end
  
end
