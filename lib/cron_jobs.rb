class CronJobs
  def self.remove_stale_sessions
    SessionCleaner.remove_stale_sessions
  end

  def self.backup_db_and_photos
    BackupUtil.backup_db_and_photos
  end

  def self.reset_expired_signs
    SignUtil.reset_expired_signs
  end
end
