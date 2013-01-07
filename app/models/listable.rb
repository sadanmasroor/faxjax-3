module Listable
  include ActionView::Helpers::TextHelper
  include UrlHelper
  include CurrencyFormatter

  PhotoDirPath = "#{Rails.root}/public/photos/listings/"
  PhotoSmallDimensions = "45x35"
  PhotoSmallSuffix = "sm"
  PhotoMediumDimensions = "150x100"
  PhotoMediumSuffix = "md"
  PhotoLargeDimensions = "480x360"
  PhotoLargeSuffix = "lg"


  module ClassMethods
    def find_by_keywords(keywords = nil, category_id = nil)
      if !category_id.nil?
        category = Category.find(category_id)
        category_ids = [category.id]
        category_ids.concat(Category.get_child_category_ids(category))
      end

      in_clause = " AND listings.category_id IN ("+category_ids.join(",")+") " if !category_ids.nil? && !category_ids.empty?
      modified_keywords = keywords.collect{|x| x+"*"}

      self.find_by_sql(["SELECT *, MATCH(sign_code, name, description, extra_values) AGAINST (? IN BOOLEAN MODE) AS relevance FROM listings WHERE MATCH(sign_code, name, description, extra_values) against(? IN BOOLEAN MODE) #{in_clause}", modified_keywords, modified_keywords]) unless keywords.nil? || keywords.empty?
    end
  end
  
  def self.included(base)
    base.extend ClassMethods
  end
  
  def _mk_url_link url
    return '' if url.blank?
    url=sanitize(url)
    u=URI.parse url
    case u
    when URI::HTTP
      u=url
    when URI::HTTPS
      u=url
    else
      u='http://' + url
    end
    
    anchor(u, :target=>'_blank') {u}
  end
  
  def url_1_link
    return if url_1.blank?
    _mk_url_link self.url_1
  end
  
  def url_2_link
    return if url_1.blank?
    _mk_url_link self.url_2
  end
  
  def mail_subject
    "Faxjax, Inc, Inquiry re: #{inquiry_subject}"
  end
  
  def mail_user message, url="https://www.faxjax.com"
    message.send_email url
  end
  
  def fields
    category = Category.find(self.category_id)
    fields = category.all_non_excluded_fields
    fields.each do |field|
      field.listing = self
    end
  end

  def field_groups
    category = Category.find(self.category_id)
    field_groups = category.field_groups
    field_groups.each do |field_group|
      if !field_group.fields.nil? && !field_group.fields.empty?
        field_group.fields.each do |field|
          field.listing = self
        end
      end
    end
  end
  
  def update_fields(fields)
    # Delegate to save_fields since it does the same checks
    save_fields(fields)
  end
  
  def save_fields(fields)
    # For each field first check if there is already a ListingValue. Update
    # if there is. If there isn't, create a new one.
    saved = false
    extra_values = String.new
    fields.each do |field_id, value|
      listing_value = nil
      self.listing_values.each do |tmp|
        if tmp.field_id.to_s == field_id
          listing_value = tmp
          break
        end
      end
      if !listing_value.nil?
        # If exists, update
        saved = listing_value.update_attribute(:value, value)
      else
        # If does not exist, save new
        listing_value = ListingValue.new
        listing_value.listing_id = self.id
        listing_value.field_id = field_id
        listing_value.value = value
        saved = listing_value.save
      end

      # If this is a checkbox then the extra_values column should have the name
      # of the checkbox added to it if it was checked
      field = Field.find(field_id)
      if field[:type] == Field::CheckBoxField.name and value == 1.to_s
        extra_values += ' '+field.name
      else
        extra_values += ' '+value
      end
    end

    # Update the "extra_values" column for full text searches
    self.update_attribute(:extra_values, extra_values)
    saved
  end
  
  def listing_value(field_id)
    value = nil
    self.listing_values.each do |listing_value|
      value = listing_value if listing_value.field_id == field_id
    end
    value
  end
  
  def increment_hits
    logger.debug("HITS IS: "+self.hits.to_s);
    self.update_attribute(:hits, self.hits+1)
  end

  def photo_path(size, num)
    path = nil
    dir = Dir.new(PhotoDirPath)
    uri = PhotoDirPath[("#{Rails.root}/public/").length..PhotoDirPath.length]
    files = Dir[PhotoDirPath+self.id.to_s+"_"+num.to_s+"_"+size+"*"]
    if !files.empty?
      filename = ''
      files.each do |name|
        if name["#{num.to_s}_#{size}"]
          filename = name[name.rindex('/')+1, name.length]
          break;
        end
      end
      path = uri+filename 
    end
    path
  end

  def expired?
    self.expires_on < Time.now
  end

  def price_alt=(value)
    # Strip the price of non-numeric chars (except for periods)
    self.price = (value.gsub(/[^\.\d]/,'').to_f * 100).to_i
  end

  def price_alt
    dollar_str self.price
  end
  
  def to_type
    if self.sign_code == ''
      basic=BasicListing.new self.attributes
      basic.id = self.id
      basic
    else
      self
    end
  end
end