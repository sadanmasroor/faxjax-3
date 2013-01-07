class BasicListing < ActiveRecord::Base
  set_table_name 'listings'
  
  # include ActionView::Helpers::TextHelper
  include Listable
  
  before_destroy :delete_photos
  before_save :set_sign_code_blank
  belongs_to :category
  belongs_to :user
  has_many :listing_values, :dependent => :destroy, :foreign_key => 'listing_id'

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
    "Your lisitng - #{name}"
  end

  def controller_name
    "basic_listings"
  end
  
  
  #  Note: no find_by_sign_code
  
  def canceled?
    false
  end

  def cancel
  end
  
  
  protected
  def validate
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
  
  def set_sign_code_blank
    self.sign_code = ''
  end
end