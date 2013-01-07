class HelpTopicsController < ApplicationController

  prepend_before_filter {|c| 
    c.permissions :admin, :new, :create, :edit, :update, :destroy
    c.titles      :index => "Help Topics",
                  :list => "Help Topics",
                  :show => "Help Topic",
                  :new => "New Help Topic",
                  :create => "New Help Topic",
                  :edit => "Edit Help Topic",
                  :update => "Edit Help Topic"
  }

  def index
    list
    render :action => 'list'
  end

  def list
    @help_topic_pages =  @help_topics = HelpTopic.paginate(:page => params[:page], :per_page => 10)
  end

  def show
    @help_topic = HelpTopic.find(params[:id])
  end

  def new
    @help_topic = HelpTopic.new
  end

  def create
    @help_topic = HelpTopic.new(params[:help_topic])
    if request.post?
      if params[:commit] == "Cancel"
        redirect_to :action => 'index'
        return
      end
      if @help_topic.save
        flash[:notice] = 'Help Topic was successfully created.'
        redirect_to :action => 'index'
      else
        render :action => 'new'
      end
    end
  end

  def edit
    @help_topic = HelpTopic.find(params[:id])
  end

  def update
    if request.post?
      @help_topic = HelpTopic.find(params[:id])
      if params[:commit] == "Cancel"
        redirect_to :action => 'index'
        return
      end
        
      if @help_topic.update_attributes(params[:help_topic])
        flash[:notice] = 'Help Topic was successfully updated.'
        redirect_to :action => 'show', :id => @help_topic
      else
        render :action => 'edit', :id => @help_topic
      end
    end
  end

  def delete
    HelpTopic.find(params[:id]).destroy
    flash[:notice] = 'Help Topic was successfully deleted.'
    redirect_to :action => 'index'
  end
end
