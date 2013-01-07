module FormHelper
  include UrlHelper
  include TagHelper
  
  def absolute_form_for method, object, options={}, &blk
    concat(_tag_start(:form, :method=>'post', :action => absolute_url_for(options))+">", blk.binding)
    fields_for(method, object, &blk)
    concat(_tag_end(:form), blk.binding) 
  end
end