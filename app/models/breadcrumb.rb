class Breadcrumb
  
  # include Reloadable
  
  attr_reader :name, :controller, :action, :id

  def initialize (name, controller = nil, action = nil, id = nil, params = nil)
    @name = name
    @controller = controller
    if @contoller == 'home'
      @action = 'index'
    else
      @action = action || 'list'
    end
    @id = id
  end
end
