class Field < ActiveRecord::Base
  set_table_name "the_fields"
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::FormTagHelper
  include ActionView::Helpers::FormOptionsHelper

  TYPES = []

  before_destroy :delete_field_values
  before_save :nullify_field_group_id_if_unsorted
  
  belongs_to :field_group
  belongs_to :category
  has_many :field_values, :order => "value ASC"

  validates_presence_of :name, :type

  # Listing is injected into the field inside of the Listing object's 'fields' and 'field_groups' methods.
  # If it's not injected then we have a problem.
  attr_accessor :listing_id, :listing

  # PROTECTED
  protected
    
  def value_of_listing_value
    listing_value = self.listing.listing_value(self.id) if !self.listing.nil?
    listing_value.value if !listing_value.nil?
  end

  def value_for_field(request)
    value = request.parameters["field_"+self.id.to_s]
    value = value_of_listing_value if value.nil?
    value
  end
  
  # PRIVATE
  private
  
  def delete_field_values
    # Destroy all field_values
    self.field_values.each do |field_value|
      field_value.destroy
    end
  end

  def nullify_field_group_id_if_unsorted
    if self.field_group_id.to_s == -1.to_s
      self.field_group_id = nil
    end
  end

end

class TextField < Field
  Field::TYPES << Field::TextField.name

  def render_html(request)
    text_field_tag("field_"+self.id.to_s, value_for_field(request), {:size => 40, :maxlength => self.maximum})
  end

  def value
    self.value_of_listing_value
  end
end

class CheckBoxField < Field
  Field::TYPES << Field::CheckBoxField.name

  def render_html(request)
    output  = hidden_field_tag("_field_"+self.id.to_s, 0)
    output += check_box_tag("field_"+self.id.to_s, 1, value_for_field(request) == 1.to_s ? true : false)
  end

  def value
    self.value_of_listing_value == "1" ? "Yes" : "No"
  end
end

class SelectField < Field
  Field::TYPES << Field::SelectField.name

  def render_html(request)
    if !self.field_values.nil?
      select_tag("field_"+self.id.to_s, 
        options_from_collection_for_select(
          self.field_values, 
          "value", 
          "value",
          value_for_field(request)
        )
      )
    end
  end

  def value
    self.value_of_listing_value
  end
end

class TextAreaField < Field
  Field::TYPES << Field::TextAreaField.name

  def render_html(request)
    text_area_tag("field_"+self.id.to_s, value_for_field(request), {:rows => 3, :cols => 40, :maxlength => self.maximum})
  end

  def value
    self.value_of_listing_value
  end
end

class StateSelectField < Field
  Field::TYPES << Field::StateSelectField.name

  def render_html(request)
    if !self.field_values.nil?
      select_tag(
        "field_"+self.id.to_s, 
        state_options_for_select(value_for_field(request))
      )
    end
  end

  def value
    self.value_of_listing_value
  end
end

class YearSelectField < Field
  Field::TYPES << Field::YearSelectField.name

  def year_options_for_select(selected = nil, start_year = Time.now.year - 50, end_year = Time.now.year)
        year_options = ""

        years = []
        year = end_year
        while year >= start_year
            years << year.to_s
            year -= 1
        end
        
       year_options += options_for_select(years, selected)
        return year_options
      end

  def render_html(request)
    if !self.field_values.nil?
      select_tag(
        "field_"+self.id.to_s,
        year_options_for_select(value_for_field(request))
      )
    end
  end

  def value
    self.value_of_listing_value
  end
end

class CountrySelectField < Field
  Field::TYPES << Field::CountrySelectField.name

  def render_html(request)
    if !self.field_values.nil?
      select_tag(
        "field_"+self.id.to_s, 
        country_options_for_select(
          value_for_field(request) ? "United States" : request.parameters["field_"+self.id.to_s]
        )
      )
    end
  end

  def value
    self.value_of_listing_value
  end
end

class RadioButtonSet < Field
  Field::TYPES << Field::RadioButtonSet.name

  def render_html(request)
    output = ''
    if !self.field_values.nil?
      self.field_values.each do |field_value|
        output += radio_button_tag("field_"+self.id.to_s, field_value.value, value_for_field(request) == field_value.value)
        output += "&nbsp;"+field_value.value
        output += " "
      end
    end
    output
  end

  def value
    self.value_of_listing_value
  end
end

