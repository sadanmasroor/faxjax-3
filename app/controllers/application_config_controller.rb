class ApplicationConfigController < ApplicationController

  prepend_before_filter {|c|
    c.permissions :admin, :edit, :update
    c.titles      :edit => "Edit Application Configuration"
  }
  
  def edit
    @application_config = ApplicationConfig.get_config
  end

  def update
    @application_config = ApplicationConfig.get_config
    if request.post?
      if params[:commit] == "Cancel"
        redirect_to_home 
        return
      end
        
      if @application_config.update_attributes(params[:application_config])
        flash[:notice] = 'Application configuration was successfully updated.'
        redirect_to :action => 'edit'
      else
        render :action => 'edit'
      end
    end
  end
end
