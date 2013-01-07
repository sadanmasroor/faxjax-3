require 'cp_r'
class BackupUtil

  def self.backup_db_and_photos
    config_data = ActiveRecord::Base.configurations[RAILS_ENV]
    username = config_data['username']
    password = config_data['password'].gsub(/[$`\\]/, "\\\\\\0")
    database = config_data['database']

    mdy = Time.now.strftime("%m-%d-%Y")

    # Delete older than 7 days backups

    # Calculate dates
    minute = 60
    hour = minute * 60
    day = hour * 24
    week_ago_time = Time.now - 7 * day
    week_ago = Date.new(week_ago_time.year, week_ago_time.month, week_ago_time.day)

    # List entries
    base_dir = "#{RAILS_ROOT}/backup"
    Dir.foreach("#{base_dir}/.") {|x|
      if x != "." && x != ".." && File.stat("#{base_dir}/"+x).directory?
        if x =~ /\d{2}-\d{2}-\d{4}/
          dir_date = Date.strptime(x, "%m-%d-%Y")
          if (dir_date < week_ago)
            FileUtils.rm_rf("#{base_dir}/"+x)
          end
        end
      end
    }
    
    # Dump the database
    FileUtils.mkdir("#{RAILS_ROOT}/backup/#{mdy}") if !FileTest.exists?("#{RAILS_ROOT}/backup/#{mdy}")
    `mysqldump -u #{username} --password=#{password} #{database} > #{RAILS_ROOT}/backup/#{mdy}/#{database}.sql`

    # Copy the photos
    FileUtils.cp_r("#{RAILS_ROOT}/public/photos", "#{RAILS_ROOT}/backup/#{mdy}/photos")

    puts "Backed up database and photos"
  end

  def self.restore_db_and_photos(mdy)
    config_data = ActiveRecord::Base.configurations[RAILS_ENV]
    username = config_data['username']
    password = config_data['password']
    database = config_data['database']

    # Restore the database
    `mysql -u #{username} --password=#{password}  #{database} < #{RAILS_ROOT}/backup/#{mdy}/#{database}.sql`
    
    # Copy the photos
    FileUtils.cp_r("#{RAILS_ROOT}/backup/#{mdy}/photos", "#{RAILS_ROOT}/public")
  end
  
end
