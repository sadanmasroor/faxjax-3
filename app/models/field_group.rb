class FieldGroup < ActiveRecord::Base
  belongs_to :category
  has_many :fields, {:order => "position ASC", :dependent => :nullify}

  def self.find_by_category(category_id = nil)
    category = Category.find(category_id)
    categories = category.self_and_ancestors.collect{|x| x.id}
    field_groups = [self.find_ungrouped_field_group(category.id)]
    field_groups.concat(self.find(:all, :conditions => ["category_id in (?)", categories], :order => "position ASC"))
  end

  def self.find_ungrouped_field_group(category_id = nil)
    category = Category.find(category_id)
    fields = category.all_fields
    fields = fields.collect{|x| x.field_group_id.nil? ? x : nil}.compact
    field_group = FieldGroup.new
    field_group.name = "Ungrouped"
    field_group.id = -1
    field_group.position = 999
    field_group.fields = fields
    field_group
  end

end
