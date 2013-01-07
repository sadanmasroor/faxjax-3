require 'fastercsv'
class Order < ActiveRecord::Base
  STATUS_NOT_VERIFIED = 0
  STATUS_OPEN = 1
  STATUS_BILLED = 2
  STATUS_PAID = 3
  STATUS_CANCELED = 4

  STATUSES = [
    ["Open", STATUS_OPEN],
    ["Billed", STATUS_BILLED],
    ["Paid", STATUS_PAID],
    ["Canceled", STATUS_CANCELED]
  ]
  
  belongs_to :vendor
  has_many :sign_lots, :dependent => :destroy

  before_update :handle_status_update

  def destroy_sign_lots
    self.sign_lots.each do |sign_lot|
      # Pull a fresh one so the associated signs are removed
      # so we don't have any problems with it trying to destroy
      # all of the associations in the sign_lots_signs table
      sign_lot = SignLot.find(sign_lot.id)  
      sign_lot.destroy
    end
  end

  def status_name
    case self.status
      when STATUS_NOT_VERIFIED
        "Not Verified"
      when STATUS_OPEN
        "Open"
      when STATUS_BILLED
        "Billed"
      when STATUS_PAID
        "Paid"
      when STATUS_CANCELED
        "Canceled"
    end
  end

  def to_csv
    # Get list of sign products to create a mapping hash of sign_product_id to sign_product for
    # easy lookup during CSV generation
    sign_products = SignProduct.find(:all, :conditions => "deleted != 1")
    spid_to_sp = {}
    sign_products.each do |sign_product|
      spid_to_sp[sign_product.id] = sign_product
    end

    vendor_name = self.vendor.name

    # Output order info
    csv_string = FasterCSV.generate(:force_quotes => true) do |csv|
      csv << ["ORDER INFORMATION"]
      csv << ["Vendor:", self.vendor.name]
      csv << ["Status:", self.status_name]
      csv << ["Created On:", self.created_on]
      csv << []
    end

    # Output sign products info
    sign_product_ids = {}
    self.sign_lots.each do |sign_lot|
      sign_product_ids[sign_lot.sign_product_id] = true unless sign_lot.sign_product_id.nil?
    end
    csv_string += FasterCSV.generate(:force_quotes => true) do |csv|
      csv << ["SIGN PRODUCTS"]
      csv << [
        "ID", "Name", "Description", "Sign Type", "Sign Duration", "Price"
      ]
    end
    sign_product_ids.each_key do |sign_product_id|
      sign_product = SignProduct.find(sign_product_id)
      csv_string += FasterCSV.generate(:force_quotes => true) do |csv|
        csv << [
          sign_product.id, sign_product.title, sign_product.description, sign_product.sign_type, sign_product.sign_duration, sign_product.price_alt
        ]
      end
    end
    csv_string += "\n"
    
    # Output sign lots
    self.sign_lots.each do |sign_lot|
      csv_string += sign_lot.to_csv(spid_to_sp)
      csv_string += "\n"
    end
    
    csv_string
  end

  private

  # Update the timestamp of the current status when it is changed
  def handle_status_update
    order = Order.find(self.id)
    if order.status != self.status # The status has changed
      case self.status
        when STATUS_BILLED
          column_name = :billed_on
        when STATUS_PAID
          column_name = :paid_on
        when STATUS_CANCELED
          column_name = :canceled_on
      end
      self.send(column_name.to_s+"=", Time.now) if !column_name.nil?
    end
  end
  
end
