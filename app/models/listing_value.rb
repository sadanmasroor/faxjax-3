class ListingValue < ActiveRecord::Base
  belongs_to :listing
  has_one :field_value
end
