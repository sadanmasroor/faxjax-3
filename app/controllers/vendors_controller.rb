class VendorsController < ApplicationController

  before_filter :add_vendors_crumb, :except => [:index, :list]

  prepend_before_filter {|c| 
    c.permissions :user, :index, :list, :show
    c.permissions :admin, :new, :create, :edit, :update, :destroy
    c.titles      :new  => "Create a Vendor",
                  :create => "Create a Vendor",
                  :edit => "Edit a Vendor",
                  :update => "Edit a Vendor",
                  :list => "Where to Buy Signs",
                  :index => "Vendors",
                  :show => "Vendor Details"
  }

  def add_vendors_crumb
    add_crumb(Breadcrumb.new(@titles[:index], "vendors")) if admin?
  end
  
  def index
    list
    render :action => 'list'
  end

  def list
    @title = "Vendors"
    @vendor_pages, @vendors = paginate_many_results Vendor, {:page => params[:page], :per_page => !params[:per_page].nil? ? params[:per_page] : 100, :conditions => ["status = ?", Vendor::ACTIVE]}
  end

  def show
    @vendor = Vendor.find(params[:id])
  end

  def new
    @vendor = Vendor.new
    # if they came from the order create page then make sure to send them back there after a vendor is added
  end

  def create
    @vendor = Vendor.new(params[:vendor])
    if @vendor.save
      flash[:notice] = 'Vendor was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @vendor = Vendor.find(params[:id])
  end

  def update
    @vendor = Vendor.find(params[:id])
    if @vendor.update_attributes(params[:vendor])
      flash[:notice] = 'Vendor was successfully updated.'
      redirect_to :action => 'show', :id => @vendor
    else
      render :action => 'edit'
    end
  end

  def destroy
    Vendor.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
