class SignProduct < ActiveRecord::Base
  include CurrencyFormatter

  PhotoDirPath = "#{Rails.root}/public/photos/sign_products/"
  PhotoSmallDimensions = "100x100"
  PhotoSmallSuffix = "sm"
  PhotoLargeDimensions = "300x300"
  PhotoLargeSuffix = "lg"

  validates_presence_of   :sign_duration, :sign_type, :price, :price_alt, :shipping_price, :shipping_price_alt, :tax, :tax_alt
  validates_numericality_of :sign_duration, :price, :shipping_price, :tax

  attr_accessor :price_alt

  def tax_alt=(value)
    # Strip the price of non-numeric chars (except for periods)
    self.tax = (value.gsub(/[^\.\d]/,'').to_f * 100).to_i
  end

  def price_alt=(value)
    # Strip the price of non-numeric chars (except for periods)
    self.price = (value.gsub(/[^\.\d]/,'').to_f * 100).to_i
  end

  

  def shipping_price_alt=(value)
    # Strip the price of non-numeric chars (except for periods)
    self.shipping_price = (value.gsub(/[^\.\d]/,'').to_f * 100).to_i
  end


  def price_alt
    dollar_str price
  end

  def tax_alt
    dollar_str tax
  end

  def shipping_price_alt
    dollar_str shipping_price
  end

  def self.active_types
    self.find_by_sql('select distinct sign_type from sign_products')
  end


  def title_string
    dur = sign_duration || '180'
    "#{title} (#{dur} days)"
  end

  def photo_path(size)
    path = nil
    dir = Dir.new(PhotoDirPath)
    uri = PhotoDirPath[("#{Rails.root}/public/").length..PhotoDirPath.length]
    files = Dir[PhotoDirPath+self.id.to_s+"_"+size+"*"]
    if !files.empty?
      filename = ''
      files.each do |name|
        if name["#{size}"]
          filename = name[name.rindex('/')+1, name.length]
          break;
        end
      end
      path = uri+filename 
    end
    path
  end

  def destroy
    self.deleted = true
    self.save
  end

  def self.destroy(sign_product)
    sign_product.deleted = true
    sign_product.save
  end

end
