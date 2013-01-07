class RestoreDataController < ApplicationController
  prepend_before_filter {|c| 
    c.permissions :admin, :index, :restore
    c.titles      :index => "Restore Data"
  }

  #  must use different named action because rails defaults to no action for index in link_to
  def main
    @dirs = []
    base_dir = "#{RAILS_ROOT}/backup"
    Dir.foreach("#{base_dir}/.") do |x|
      fstat = File.stat("#{base_dir}/"+x)
      if x != "." && x != ".." && fstat.directory? && x =~ /\d{2}-\d{2}-\d{4}/
        @dirs << fstat.mtime
      end
    end
    @dirs.sort!.reverse!
  end

  def restore
    mdy = params[:date]
    if !mdy.nil? && mdy =~ /\d{2}-\d{2}-\d{4}/
      begin
        BackupUtil.restore_db_and_photos(mdy)
      rescue
        flash[:warning] = "Error restoring data"
      else
        flash[:notice] = "Data restored"
      end
    else
      flash[:warning] = "No data available for that date"
    end
    redirect_to :action => "index"
  end
end
