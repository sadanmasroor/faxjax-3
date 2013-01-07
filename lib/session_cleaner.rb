class SessionCleaner
  def self.remove_stale_sessions num=nil
    num ||= !ApplicationConfig.get_config.nil? ? ApplicationConfig.get_config.session_timeout_minutes : 15
    CGI::Session::ActiveRecordStore::Session.destroy_all( ['updated_at <?', num.minutes.ago] )
    puts "Destroyed sessions ("+num.to_s+" minute timeout)"
  end
end
