class OrdersController < ApplicationController

  before_filter :add_vendors_crumb, :except => [:index, :list]

  prepend_before_filter {|c| 
    c.permissions :user, :index, :list, :show
    c.permissions :admin, :new, :create, :create_step_2, :create_step_3, :edit, :update, :update_status, :destroy, :destroy_sign_lot
    c.titles      :new  => "Create an Order",
                  :create => "Create an Order",
                  :new_step_2  => "Create an Order",
                  :create_step_2  => "Create an Order",
                  :new_step_3  => "Verify Order",
                  :create_step_3  => "Verify Order",
                  :edit => "Edit Order",
                  :update => "Edit Order",
                  :list => "Orders",
                  :index => "Orders",
                  :show => "Order Details"
  }

  def add_vendors_crumb
    add_crumb(Breadcrumb.new(@titles[:index], "orders")) if admin?
  end
  
  def index
    list
    render :action => 'list'
  end

  def list
    @order_pages = @orders = Order.paginate(:page => params[:page], :per_page => 50)
  end

  def show
    @order = Order.find(params[:id])
  end

  def export_csv
    @order = Order.find(params[:id])
    send_data(@order.to_csv,
      :type => 'text/csv; charset=iso-8859-1; header=present',
      :filename => 'export.csv')    
  end

  def new
    @order = Order.new
    # Handle edit mode
    @mode = params[:mode]
  end

  def new_step_2
    @order = Order.find(params[:id]) 
    @sign_lot = SignLot.new
    # Handle edit mode
    @mode = params[:mode]
  end

  def new_step_3
    @order = Order.find(params[:id])
    # Handle edit mode
    @mode = params[:mode]
  end

  def create
    @order = Order.new(params[:order])
    if request.post?
      if params[:commit].include?("Cancel")
        redirect_to :action => 'index'
        return
      end
      if @order.save
        redirect_to :action => 'new_step_2', :id => @order.id
      else
        render :action => 'new'
      end
    end
  end

  def create_step_2
    @order = Order.find(params[:id])
    @sign_lot = SignLot.new(params[:sign_lot])
    if request.post?
      if params[:commit] == "Cancel"
        if !params[:mode].nil? && params[:mode] == "edit"
          # Just editing, don't delete the order
          redirect_to :action => "index"
          return
        else
          # Destroy the entire order up until this point
          order = Order.find(params[:id])
          logger.error("Destroying Sign Lots")
          order.destroy_sign_lots
          logger.error("Destroying Order")
          order.destroy
          redirect_to :action => "index"
          return
        end
      end
      
      # Make sure we have that many signs available
      signs = Sign.find_salable(@sign_lot.quantity.to_i)
      if @sign_lot.quantity.to_i > 0 && (signs.nil? || signs.empty? || signs.length < @sign_lot.quantity.to_i)
        flash[:warning] = "There are only #{signs.length} unused signs available."
        redirect_to :action => "new_step_2", :id => params[:id], :mode => params[:mode]
        return
      end
      
      # First we'll save the sign lot. 
      if (@sign_lot.quantity.nil? || @sign_lot.quantity == 0) &&
         (@sign_lot.price.nil? || @sign_lot.price == 0) &&
         params[:commit].include?("Continue")
        redirect_to :action => 'new_step_3', :id => params[:id], :mode => params[:mode]
        return
        
      elsif @sign_lot.save
        # If there is a name associated with it we will update it with 
        # no order_id and use it as a template for the sign lot to be
        # saved on the order.
        if !@sign_lot.name.nil? && !@sign_lot.name.empty?
          @sign_lot.update_attribute(:order_id, nil)
          @sign_lot = SignLot.new_from_template(@sign_lot.id)
          @sign_lot.order_id = params[:sign_lot][:order_id]
          @sign_lot.save
        end
        
        @order.sign_lots << @sign_lot

        # Add specified quantity of signs to the sign lot
        # and change their type/duration/sign_product_id to match the sign lot
        @sign_lot.add_signs(signs)
        ids = []
        signs.each do |sign|
          ids << sign.id
        end
        ids = ids.join(",")
        Sign.reset(ids) # Reset the signs which will also reset their keys
        Sign.update_all(["vendor_id = ?, duration = ?, type = ?, sign_product_id = ?",
                         @sign_lot.order.vendor.id, 
                         @sign_lot.sign_product.sign_duration, 
                         @sign_lot.sign_product.sign_type,
                         @sign_lot.sign_product_id
                        ],
                        "id IN ("+ids+")") if !ids.nil? && !ids.empty?
        
        if params[:commit].include?("Continue")
          redirect_to :action => 'new_step_3', :id => params[:id], :mode => params[:mode]
          return
        else
          redirect_to :action => 'new_step_2', :id => params[:id], :mode => params[:mode]
          return
        end
      else
        logger.debug("===============")
        logger.debug(@sign_lot.errors.count)
        render :template => 'orders/new_step_2'
      end
    end
  end

  def create_step_3
    @order = Order.find(params[:id])
    @sign_lot = SignLot.new(params[:sign_lot])
    if request.post?
      if params[:commit].include?("Revise")
        redirect_to :action => "new_step_2", :id => params[:id], :mode => params[:mode]
        return
      elsif params[:commit].include?("Cancel")
        if !params[:mode].nil? && params[:mode] == "edit"
          # Just editing, don't delete the order
          redirect_to :action => "index"
          return
        else
          # Destroy the entire order up until this point
          order = Order.find(params[:id])
          logger.error("Destroying Sign Lots")
          puts("Destroying Sign Lots")
          order.destroy_sign_lots
          logger.error("Destroying Order")
          puts("Destroying Order")
          order.destroy
          puts("After Destroying Order")
          redirect_to :action => "index"
          return
        end
      end
      if @order.update_attribute(:status, Order::STATUS_OPEN)
        unless params[:promo_code].nil?
          @order.promo_code = params[:promo_code]
          @order.save
        end
        if !params[:mode].nil? && params[:mode] == 'edit'
          flash[:notice] = "Order updated"
        else
          flash[:notice] = "Order created"
        end
        redirect_to :action => "list"
      else
        flash[:warning] = "There was an error"
        redirect_to :action => "new_step_3", :id => params[:id], :mode => params[:mode]
      end
    end
  end

  def sign_lot_template
    @sign_lot = SignLot.find(params[:id])
  end

  def destroy_sign_lot
    if !params[:id].nil?
      sign_lot = SignLot.find(params[:id])
      if SignLot.destroy(params[:id])
        render :nothing => true
      else
        render :nothing => true, :status => 500
      end
    else
      render :nothing => true, :status => 500
    end
  end

  def edit
    @order = Order.find(params[:id])
    @mode = 'edit'
    render :action => 'new_step_3'
  end

  def update
    @order = Order.find(params[:id])
    if request.post?
      if params[:commit] == "Cancel"
        redirect_to :action => 'index'
        return
      end
        
      if @order.update_attributes(params[:order])
        flash[:notice] = 'Order was successfully updated.'
        redirect_to :action => 'show', :id => @order
      else
        render :action => 'edit'
      end
    end
  end

  def update_status
    @order = Order.find(params[:id])
    if !@order.update_attribute(:status, params[:status])
      render :nothing => true, :status => 500
    end
  end

  def destroy
    order = Order.find(params[:id])
    order.destroy_sign_lots
    order.destroy
    redirect_to :action => 'index'
  end
end
