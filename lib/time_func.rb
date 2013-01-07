module TimeFunc
  SECONDS_IN_DAY = 86400

  def self.calc_days time, &blk
    (yield(time) / TimeFunc::SECONDS_IN_DAY).round
  end
  
  def self.day_to_s days
    days == 1 ? "#{days} day" : "#{days} days"
  end
  
  def self.days_from_now time
    self.calc_days time do |the_time|
      the_time - Time.now
    end
  end
  
  def self.days_from_now_as_string time
    self.day_to_s(self.days_from_now(time))
  end
  
  def self.days_ago time
    self.calc_days(time) do |the_time|
      Time.now - the_time
    end
  end
  
  def self.days_ago_as_string time
    self.day_to_s(self.days_ago(time))
  end
  
  def self.midnight time
    Time.local(*[time.year, time.month, time.day])
  end
  
  def self.twenty3_59_59 time
    Time.local(*[time.year, time.month, time.day, 23, 59, 59])
  end
end