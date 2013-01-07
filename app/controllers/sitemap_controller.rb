class SitePage
  def initialize time, our_controller, the_controller, action, the_id=nil
    @our_controller = our_controller
    @the_controller = the_controller
    
    @action = action
    @the_id = the_id
    @time = time
  end
  def updated_at
    @time
  end
  def url
    @our_controller.url_for :controller => @the_controller, 
      :action => @action, 
      :id => @the_id
  end
end

#  genearets dynamic sitemap.xml
class SitemapController < ApplicationController

  def sitemap
    @pages =[]
    #  get last modief for static pages
    static_last_modified = HomeHelper::ContactInfo.from_yaml.last_modified
    %w{home}.each do |cntrlr|
      %w{index about tos privacy}.each do |actn|
        @pages << SitePage.new(static_last_modified, self, cntrlr, actn)
      end
    end
    
    #  TODO 0 update this for recent added signs
    @pages << SitePage.new(static_last_modified, self, "sign_products", "list")
    
    Listing.find(:all).each do |l|
      @pages << SitePage.new(l.updated_on, self, "listings", "show", l.id) unless l.expired?
    end
    
    # set header last modified date to most recent page
    headers["Last-Modified" ] = @pages.max_by {|e| e.updated_at}.updated_at.httpdate
    render :layout => false
  end
end
