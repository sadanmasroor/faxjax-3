class CategoriesController < ApplicationController
  before_filter :add_categories_crumb, :except => [:index, :list]

  prepend_before_filter {|c|
    c.permissions :admin, :index, :add, :delete, :edit, :resort_field_groups, :delete_field_group, :add_field_groups, :edit_field_group,
                  :add_fields,:edit_field, :delete_field, :edit_field_values, :delete_field_value
    c.titles      :index => "Categories",
                  :list => "Categories",
                  :add => "Add Subcategory",
                  :edit => "Edit Category",
                  :add_fields => "Add Fields",
                  :edit_field => "Edit Field",
                  :edit_field_values => "Edit Field Values",
                  :add_field_groups => "Add Field Groups",
                  :edit_field_group => "Edit Field Group"
  }

  def add_categories_crumb
    add_crumb(Breadcrumb.new(@titles[:index], "categories"))
  end

  def index
    list
  end
  
  # List Categories
  def list
    @root_category = [Category.find(Category::ROOT_ID)]
    if request.post?
      if params[:commit].include?("Edit")
        redirect_to :action => "edit", :id => params[:category_id]
      elsif params[:commit].include?("Delete")
        redirect_to :action => "delete", :id => params[:category_id]
      elsif params[:commit].include?("Add")
        redirect_to :action => "add", :category_id => params[:category_id]
      end
    else
      render :action => 'list'
    end
  end

  # Add Category
  def add
    @root_category = [Category.find(Category::ROOT_ID)]
    @category = Category.new(params[:category])
    @category.parent_id = params[:category_id] if !params[:category_id].nil?
    if request.post?
      if (!params[:excluded_field_ids].nil?)
        @category.excluded_field_ids = params[:excluded_field_ids].join(",").gsub(/^,/,'').gsub(/,,/,',')
      else
        @category.excluded_field_ids = nil 
      end
      
      if params[:commit].include?("Cancel")
        redirect_to :action => "list"
      elsif @category.save
        flash[:notice] = "Created new category #{@category.name}."
        if (!params[:add_fields].nil?)
          redirect_to :action => "add_fields", :category_id => @category.id
        else
          redirect_to :action => "list"
        end
      end
    end
  end

  # Delete Category
  def delete
    if params[:id] == Category::ROOT_ID
      flash[:warning] = "You cannot delete the top level category"
    end
    @category = Category.find(params[:id])
    if @category.destroy
      flash[:notice] = "Category deleted."
      redirect_to :action => "list"
    end
  end

  # Edit Category
  def edit
    @root_category = [Category.find(Category::ROOT_ID)]
    @category = Category.find(params[:id])
    if params[:id] == Category::ROOT_ID.to_s
      flash[:warning] = "You cannot edit the top level category"
      redirect_to :action => "list" 
    end
    

    if request.post?
      @category = Category.find(params[:category][:id])
      @category.attributes = params[:category]
      
      if !params[:excluded_field_ids].nil?
        @category.excluded_field_ids = params[:excluded_field_ids].join(",").gsub(/^,/,'').gsub(/,,/,',')
      else
        @category.excluded_field_ids = nil 
      end
      
      if params[:commit].include?("Cancel")
        redirect_to :action => "list"
      else
        if @category.save
          flash[:notice] = "Updated category #{@category.name}."
          if params[:commit].include?("Finish")
            redirect_to :action => "list"
          else
            redirect_to :id => @category.id
          end
        end
      end
    end
  end

  # Add Fields
  def add_fields
    @field = Field.new(params[:field])
    @field.category_id = params[:category_id] if !params[:category_id].nil?
    @field[:type] = params[:field][:type] if !params[:field].nil? && !params[:field][:type].nil?
    if request.post?
      if params[:commit].include?("Cancel")
        redirect_to :action => "edit", :id => @field.category.id
        return
      elsif params[:commit].include?("Add Another")
        continue = true
      else
        continue = false;
      end
      
      if @field.save
        flash[:notice] = "#{@field[:type]} '#{@field.name}' saved."
        case @field['type']
          when Field::SelectField.name, Field::RadioButtonSet.name
            flash[:notice] = "#{@field[:type]} '#{@field.name}' saved. Please add values."
            redirect_to :action => "edit_field_values", 
                        :field_id => @field.id, 
                        :add_another_field => continue
            return
        end
        if continue
          redirect_to :action => "add_fields", 
                      :category_id => @field.category_id
        else
          redirect_to :action => "edit", :id => @field.category_id
        end
      end
    end
  end

  # Edit Field
  def edit_field
    @field = Field.find(params[:id])
    @field.attributes = params[:field]
    @field[:type] = params[:field][:type] if !params[:field].nil? && !params[:field][:type].nil?
    if request.post?
      if params[:commit].include?("Cancel")
        redirect_to :action => "edit", :id => @field.category.id
      elsif @field.save
        flash[:notice] = "#{@field[:type]} '#{@field.name}' saved."
        redirect_to :action => "edit",
                    :id => @field.category_id
      end
    end
  end

  def delete_field
    @field = Field.find(params[:id])
    category_id = @field.category_id
    if @field.destroy
      flash[:warning] = "Field deleted."
      redirect_to :action => "edit",
                  :id => category_id
    end
  end


  # Edit Field Values
  def edit_field_values
    if params[:id].nil?
      @field_value = FieldValue.new(params[:field_value])
      @field_value.field_id = params[:field_id] if !params[:field_id].nil?
    else
      @field_value = FieldValue.find(params[:id])
      @field_value.attributes = params[:field_value]
    end
    if request.post?
      if params[:commit].include?("Cancel")
        redirect_to :action => "edit_field",
                    :id => @field_value.field_id
      else
        if @field_value.save
          flash[:notice] = "Value '#{@field_value.value}' saved."
          if params[:commit].include?("Add Another")
            redirect_to :field_id => @field_value.field_id,
                        :id => nil,
                        :add_another_field => params[:add_another_field], 
                        :category_id => @field_value.field.category_id
          else
            if !params[:add_another_field].nil? && params[:add_another_field] == "true"
              redirect_to :action => "add_fields", 
                          :category_id => @field_value.field.category_id
            else
              redirect_to :action => "edit_field",
                          :id => @field_value.field.category_id
            end
          end
        end
      end
    end
  end

  def delete_field_value
    @field_value = FieldValue.find(params[:id])
    field_id = @field_value.field_id
    if @field_value.destroy
      flash[:warning] = "Field value deleted."
      redirect_to :action => "edit_field_values",
                  :field_id => field_id
    end
  end

  def resort_field_groups
    field_group_ids = params["resort_field_groups"]
    if !field_group_ids.nil?
      field_group_ids.each_index do |i|
        field_group_id = field_group_ids[i]
        next if field_group_id == "-1"
        field_group = FieldGroup.find(field_group_id)
        field_group.position = i
        puts field_group.name
        field_group.save
      end
    end

    params.each_key do |key|
      if key =~ /resort_field_group_fields_/
        field_ids = params[key].collect{|x| x.to_i}
        field_ids.each_index do |i|
          field_id = field_ids[i]
          field = Field.find(field_id)
          field.position = i
          field.save
        end
      end
    end

    @category = Category.find(params[:id])
    @field_groups = @category.field_groups
    render :partial => "field_group_list"
  end

  def refresh_resort
    @category = Category.find(params[:id])
    @field_groups = @category.field_groups
    render :partial => "field_resort_list"
  end

  def update_field_group_for_field
    @field = Field.find(params[:id])
    @field.field_group_id = params[:field_group_id]
    if @field.save
      @category = Category.find(params[:category_id])
      @field_groups = @category.field_groups
      render :partial => "field_group_list"
    end
  end

  def add_field_groups
    @field_group = FieldGroup.new(params[:field_group])
    @field_group.category_id = params[:category_id] if !params[:category_id].nil?
    if request.post?
      if params[:commit].include?("Cancel")
        redirect_to :action => "edit", :id => @field_group.category.id
        return
      else
        if (@field_group.save)
          flash[:notice] = "'#{@field_group.name}' saved."
          if params[:commit].include?("Add Another")
            redirect_to :action => "add_field_groups", 
                        :category_id => @field_group.category_id
          else
            redirect_to :action => "edit", :id => @field_group.category_id
          end
        end
      end
    end
  end

  def edit_field_group
    @field_group = FieldGroup.find(params[:id])
    @field_group.attributes = params[:field_group]
    if request.post?
      if params[:commit].include?("Cancel")
        redirect_to :action => "edit", :id => @field_group.category.id
      elsif @field_group.save
        flash[:notice] = "'#{@field_group.name}' saved."
        redirect_to :action => "edit",
                    :id => @field_group.category_id
      end
    end
  end

  def delete_field_group
    @field_group = FieldGroup.find(params[:id])
    category_id = @field_group.category_id
    if @field_group.destroy
      flash[:warning] = "Field group deleted."
      redirect_to :action => "edit",
                  :id => category_id
    end
  end
end
