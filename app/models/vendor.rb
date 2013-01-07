class Vendor < ActiveRecord::Base
  # Faxjax vendor ID is 99999 - this should be rethought
  FAXJAX_ID = 99999
  
  ACTIVE = 0
  INACTIVE = 1 
  
  has_many :orders

  validates_presence_of :name

  def destroy
    self.status = Vendor::INACTIVE
    self.save.to_s
  end

  def self.destroy(id)
    vendor = Vendor.find(id)
    vendor.status = Vendor::INACTIVE
    vendor.save.to_s
  end

  def self.find_all_active
    Vendor.find(:all, :conditions => ["status = ?", Vendor::ACTIVE])
  end

end
