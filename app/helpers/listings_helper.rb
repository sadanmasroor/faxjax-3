module ListingsHelper
  def link_hash object
    {:controller => object.controller_name, :action => 'show', :id => object.id}
  end
  
  def link_hash_search object
    {:controller => (object.sign_code.blank? ? "basic_listings" : "listings"), :action => 'show', :id => object.id}
  end
end
