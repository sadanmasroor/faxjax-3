class Category < ActiveRecord::Base

  ROOT_ID = 1

  before_destroy :delete_children
  
  has_many :listings, :dependent => :destroy
  has_many :fields, {:dependent => :destroy, :order => "position ASC"}
  has_many :field_groups, {:dependent => :destroy, :order => "position ASC"}
  
  acts_as_tree :order => "name"

  validates_presence_of     :name #,  :parent_id

  def validate
    errors.add(:parent_id, "cannot be the same as the category") if self.parent_id == self.id
    errors.add(:parent_id, "cannot be blank") if parent_id.nil? and id != Category::ROOT_ID
  end
  
  def self.root
    Category.find(Category::ROOT_ID)
  end

  def root?
    self.id == ROOT_ID
  end

  def self.listing_types
    self.find(:all, :conditions => ["parent_id = ?", 1]).map(&:name)
  end

  def fields
    Field.find(:all, :conditions => ["category_id = ?", self.id], :order => "position ASC")
  end
  
  def self_and_ancestors
    ancestors = self.ancestors
    ancestors << self
    ancestors
  end

  def top_level_category
    anc = self_and_ancestors
    top = anc.detect{|e| e.parent_id == Category::ROOT_ID}
    if top.nil?
      top = Category.find(Category::ROOT_ID)
    end
    top
  end
  
  def self_and_descendants_ids
    [self.id] + self.descendants.map(&:id)
  end
  
  def all_listings
    Listing.find(:all, :conditions => ["category_id in (#{self_and_descendants_ids.join(',')}) AND expires_on > ? AND sign_code IS NOT NULL", Time.now-10.minutes])
  end

  def listings
    Listing.find(:all, :conditions => ["category_id = ? AND expires_on > ? AND sign_code IS NOT NULL", self.id, Time.now-10.minutes])
  end


  def all_fields
    fields = []
    self.self_and_ancestors.each do |category| 
      fields.concat(category.fields)
    end
    fields
  end

  def field_groups
    field_groups = FieldGroup.find_by_category(self.id)
  end

  def all_non_excluded_fields
    fields = []
    tmp_fields = []
    self.self_and_ancestors.each do |category| 
      tmp_fields.concat(category.fields)
    end
    tmp_fields.each do |field|
      if !self.excluded_fields.include?(field)
        fields << field
      end
    end
    fields
  end

  def ancestor_fields
    fields = []
    self.ancestors.each do |category| 
      fields.concat(category.fields)
    end
    fields
  end

  def excluded_fields
    fields = self.all_fields.collect {|x| x if !self.excluded_field_ids.nil? && self.excluded_field_ids.include?(x.id.to_s)}
    fields.compact if !fields.nil?
  end

  def excluded_field_ids_array
    self.excluded_field_ids.split(",") if !self.excluded_field_ids.nil?
  end


  def descendants
    results = []
    self.children.each  do |child|
      results << child
      results += child.descendants
    end
    results
  end

  # PRIVATE
  private

  def delete_children
    if !self.children.empty?
      self.children.each do |subcategory|
        subcategory.destroy
      end
    end
  end
  
  
  
  def self.get_child_category_ids(category)
    category_ids = [category.id]
    if !category.children.empty?
      category.children.each do |subcat|
        category_ids.concat(Category.get_child_category_ids(subcat))
      end
    end
    category_ids
  end

end
