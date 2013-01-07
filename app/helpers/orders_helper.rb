require "object_try"

module OrdersHelper
  def ok attrib 
    attrib.nil? ? 'N/A' : h(attrib)
  end
end
