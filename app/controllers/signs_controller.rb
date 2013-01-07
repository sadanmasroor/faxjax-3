class SignsController < ApplicationController

  prepend_before_filter {|c| 
    c.permissions :user, :list, :show
    c.permissions :admin, :edit, :update, :reset
    c.titles      :activate => "Activate a Listing",
                  :show => "Sign Details",
                  :list => "Your Signs",
                  :index => "Your Signs",
                  :edit => "Edit Sign",
                  :checkout => "Checkout"
  }

  def index
    list
    render :action => 'list'
  end
  
  def activate
    @sign = Sign.new
    if !logged_in
      redirect_to_login
      session[:activating_sign] = true
      session[:activating_sign_code] = params[:code]
      session[:activating_sign_key1] = params[:key1]
      session[:activating_sign_key2] = params[:key2]
      session[:activating_sign_key3] = params[:key3]

      flash[:info] = "Please <a href=\"#{url_for :controller => 'home', :action => 'sign_in'}\">sign in</a> or <a href=\"#{url_for :controller => 'users', :action => 'new'}\">create an account</a> before activating a sign."
    else
      if request.post?
        code = params[:code]
        key = params[:key1]+params[:key2]+params[:key3]

        # Try to activate the sign
        begin
          sign = Sign.activate(active_user, code, key)
        rescue => details
          flash[:warning] = details
          redirect_to :action => "activate",
                      :code => params[:code],
                      :key1 => params[:key1],
                      :key2 => params[:key2],
                      :key3 => params[:key3]
          return
        end

        if !sign.nil? && !sign.errors.empty?
          @sign = sign
          render :action => "activate"
        else
          flash[:notice] = "Sign #{sign.code.upcase} is now activated. You are now ready to <a href=\"#{url_for :controller => 'listings', :action => 'add'}\">add a new listing</a>!"
          redirect_to :action => "show", :id => sign
        end
      end
    end
  end

  def show
    @sign = Sign.find(params[:id])
    if @sign.user_id != active_user.id
      flash[:warning] = "You do not own that sign!"
      redirect_to :controller => "home"
    end
  end

  def edit
    @sign = Sign.find(params[:id])
  end

  def update
    @sign = Sign.find(params[:id])
    if request.post?
      if params[:commit] == "Cancel"
        redirect_to :action => 'index'
        return
      end
        
      if @sign.update_attributes_with_listing(params[:sign]) do |message|
          flash[:info] = message
        end
        flash[:notice] = 'Sign was successfully updated.'
        redirect_to :action => 'list', :code => @sign.code
      else
        render :action => 'edit'
      end
    end
  end

  def reset
    # Reset the sign and redirect back to sign list
    Sign.reset(params[:id])
    flash[:notice] = "Sign was successfully reset."
    redirect_to :action => "list", :code => Sign.find(params[:id]).code
  end

  def list
    if admin?
      conditions = nil
      if !params[:code].nil? && !params[:code].empty?
        conditions = "code = '#{params[:code]}'"
      end
      @title = "Signs"
      @signs_pages, @signs = paginate_many_results Sign, {:conditions => conditions, :page => params[:page], :per_page => !params[:per_page].nil? ? params[:per_page] : 25}
    else
      @signs = active_user.signs
      @used_signs = []
      @unused_signs = []
      @signs.each do |sign|
        if !sign.listed?
          @unused_signs << sign
        else
          @used_signs << sign
        end
      end
    end
  end
end
