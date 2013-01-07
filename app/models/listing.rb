require 'profanity_filter'

class Listing < ActiveRecord::Base
  include ActionView::Helpers::TextHelper
  include Listable

  before_destroy :delete_photos
  
  belongs_to :category
  belongs_to :sign
  belongs_to :user
  has_many :listing_values, :dependent => :destroy

  validates_presence_of     :category_id,
                            :user_id,
                            :name,
                            :expires_on,
                            :description,
                            :price

  validates_length_of       :name,
                            :maximum => 128,
                            :message => "must contain less than %d characters"
  validates_length_of       :description,
                            :maximum => 4000,
                            :message => "must contain less than %d characters"
  validates_length_of       :url_1,
                            :maximum => 500,
                            :message => "must contain less than %d characters"
  validates_length_of       :url_2,
                            :maximum => 500,
                            :message => "must contain less than %d characters"

  # attr_accessor             :price_alt
  def inquiry_subject
    "Sign: #{sign_code} - #{name}"
  end

  def controller_name
    "listings"
  end
  

  def self.find_by_code(code = nil, options = {})
    if options[:wildcard]
      code = code[0..4] + '%'
      op = 'like'
      slice = :all
    else
      code = code[0..4]
      op = '='
      slice = :first
    end
    l = nil
    l=self.find(slice, :conditions => ["sign_code #{op} ?", code]) unless code.nil?
    l = l.first if !l.nil? and l.kind_of? Array and l.length == 1
    #  otherwise return all of them
    l
  end
  
  def canceled?
    self.sign_id.nil?
  end

  def cancel
    self.update_attribute(:sign_id, nil)
  end
  


  protected

  def validate
    # Validate the sign does not have a listing
    sign = Sign.find(sign_id) if !sign_id.nil?
    errors.add(:sign_id, "must not already be in use") if !sign_id.nil? and !sign.listing.nil? and self.id.nil?
    
    errors.add(:price, "should be positive") if price.nil? || price <= 0
    errors.add(:price, "must be less than $99999999.00") if !price.nil? && price > 9999999999
    if category_id.nil? || category_id <= Category::ROOT_ID
      errors.add(:category_id, "must be selected")
    else
      errors.add(:category_id, "does not allow listings") if !Category.find(category_id).allow_listings 
    end

    # Profanity filter
    if ProfanityFilter.profane?(description)
      errors.add(:description, "cannot include profanity! (The word '#{ProfanityFilter.profane_word(description).to_s.strip}' is not allowed)")
    end
  end

  # After Validations is depreciated in Rails 3. Edited by Bill .

  #def after_validation
   # if !errors.empty?
      #self.price = self.price / 100
   # end
  # end


  # PRIVATE
  private

  def delete_photos
    # Delete associated photos
    files = Dir[PhotoDirPath+self.id.to_s+"_*"]
    files.each do |file|
      File.delete(file)
    end
  end
  
end
