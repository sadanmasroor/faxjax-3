class FieldValue < ActiveRecord::Base
  belongs_to :field
  validates_presence_of :value
end
