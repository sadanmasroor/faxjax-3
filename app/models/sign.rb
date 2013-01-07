require 'fastercsv'
ActiveRecord::Base.inheritance_column = "activerecordtype"
class Sign < ActiveRecord::Base
  include ActionView::Helpers::DateHelper

  has_and_belongs_to_many :sign_lots, :join_table => :sign_lots_signs
  belongs_to :user
  belongs_to :vendor
  belongs_to :sign_product
  has_one :listing

  # Populated at the end of this file
  TYPES = []
  
  validates_presence_of :code, :key
  validates_format_of :code, :with => /^\d[A-Z0-9]{4}$/,
                              :message => "The sign code is improperly formatted. It needs to be 9XXXX"
  validates_uniqueness_of :code
  validates_length_of :code, :is => 5, :message => "Sign code must be %d characters"
  validates_length_of :key, :is => 12, :message => "Sign PIN must be %d characters" 

  before_create :run_before_create


  def expires_on
    return Time.now if self.activated_on.nil? || self.duration.nil?
    self.activated_on + duration.to_i.days
  end

  def expired?
    self.expires_on < Time.now
  end

  def expires_in
    TimeFunc.days_from_now(expires_on)
  end

  def code_and_expire
    if !self.expired?
      code+" ("+ TimeFunc::days_from_now_as_string(self.expires_on)+" left)"
    else
      code+" (Expired)"
    end
  end
  
  def listed?
    !self.listing.nil?
  end

  def active?
    !self.activated_on.nil?
  end

  def to_csv(vendor_name = nil)
    csv_string = FasterCSV.generate(:force_quotes => true) do |csv|
      csv << [
        self.id, vendor_name.nil? ? "" : vendor_name , self.vendor_id, self[:type], self.code, self.key, self.duration, self.updated_on
      ]
    end
    csv_string
  end

  def self.array_to_csv(signs, vendor_name = nil)
    return if signs.nil? or signs.empty?

    csv_string = FasterCSV.generate(:force_quotes => true) do |csv|
      csv << [
        "ID", "Vendor Name", "Vendor ID", "Type", "Code", "PIN", "Duration", "Updated On"
      ]
      signs.each do |sign|
        csv << [
          sign.id, vendor_name.nil? ? "" : vendor_name, sign.vendor_id, sign[:type], sign.code, sign.key_string, sign.duration, sign.updated_on
        ]
      end
    end
    csv_string
  end

  def key_string
    tmp_key = self.key.to_s
    tmp_key[0..3]+"-"+tmp_key[4..7]+"-"+tmp_key[8..11]
  end

 
  def update_attributes_with_listing(attributes)
    listing = Listing.find_by_code self.code
    result = update_attributes(attributes)

    unless !result or listing.nil? or listing.kind_of? Array
      listing.sign_code = self.code
      listing.save
      yield "Listing #{listing.id} was also changed" if block_given?
    end
    
    result
  end
 
  #  self methods
  def self.reset(ids)
    if ids.instance_of? Fixnum or ids.instance_of? String
      ids = [ids]
    end
    ids = ids.join(",")

    Listing.update_all("sign_id = NULL", "sign_id IN("+ids+")") if !ids.nil? && !ids.empty?
    self.update_all("activated_on = NULL,
                     updated_on = NULL,
                     user_id = NULL,
                     listing_id = NULL,
                     vendor_id = NULL,
                     duration = NULL,
                     `type` = NULL,
                     `key` = ROUND(RAND()*(999999999999-100000000000)+100000000000)", # Reset the key using MySQL RAND() function
                     "id IN("+ids+")") if !ids.nil? && !ids.empty?
  end

  def self.activate(user, code, key)
    raise "You must be logged in to activate a sign." if user.nil?

    sign = Sign.find(:first, :conditions => [ "code = ? AND `key`= ?", code, key])
    
    raise "Sign code and PIN do not match." if sign.nil?
    raise "Sign is already active. If you feel that this is an error please contact Customer Care at 1-855-5-FAXJAX." if sign.active?
    
    sign.user_id = user.id
    sign.activated_on = Time.now
    sign.save
    sign
  end

  def self.find_salable(quantity = 0)
    self.find(:all, :conditions => "`type` IS NULL AND user_id IS NULL AND vendor_id IS NULL and listing_id IS NULL AND activated_on IS NULL", :limit => quantity)
  end
                                                                         
  def self.find_by_code_and_key(code = nil, key = nil)
    self.find(:first, :conditions => ["code = ? AND `key` = ?", code, key]) unless code.nil? or key.nil?
  end
  
  private
  def run_before_create
    self.duration = 180
  end
  
end

