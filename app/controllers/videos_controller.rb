class VideosController < ApplicationController
	
		  prepend_before_filter {|c|
    c.permissions :admin, :new, :index, :delete, :edit, :update
    c.titles     :new => "Add a Video",
                  :index => "Listing Videos",
                  :edit => "Edit Video",
                  :update => "Update Video"
  }
  
  def index
    @videos = Video.find(:all)
  end


  def show
    @video = Video.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @video }
    end
  end
 
  def new
	@video=Video.new
  end


  def create
        @video=Video.new(:title=>params[:title], :embed_code=>params[:embed_code])
	if @video.save
	p @video.inspect
	flash[:success]="Category has been added successfully"
	redirect_to :controller=>'videos', :action=>'index'
	else
	flash[:success]="Invalide data entry"
	redirect_to :controller=>'videos', :action=>'new'
	end
  end
  
  
  def edit
    @video = Video.find(params[:id])
  end
  

  def update
    @video = Video.find(params[:id])
    respond_to do |format|
      if @video.update_attributes(:title=>params[:title], :embed_code=>params[:embed_code])
      redirect_to :controller=>'videos', :action=>'index'
      else
	flash[:success]="Invalide data entry"
	redirect_to :controller=>'videos', :action=>'edit'
	end
    end
  end
  
  def destroy
  @video = Video.find(params[:id])
  @video.destroy
  redirect_to :controller=>'videos', :action=>'index'
  end  

  def video
	@video = Video.find(params[:id])
  end

  
end
