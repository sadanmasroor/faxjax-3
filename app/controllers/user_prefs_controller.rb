class UserPrefsController < ApplicationController

  prepend_before_filter {|c|
    c.permissions :user, :edit
    c.titles      :edit => "Your Preferences"
  }

  def edit
    @user_prefs = UserPrefs.find(params[:id])
  end

  def update
    @user_prefs = UserPrefs.find(params[:id])
    if @user_prefs.update_attributes(params[:user_prefs])
      flash[:notice] = 'Your preferences were successfully updated.'
      redirect_to :action => 'edit', :id => @user_prefs
    else
      render :action => 'edit'
    end
  end
end
