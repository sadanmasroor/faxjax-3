class Tracking < ActiveRecord::Base

  def self.track code, ip, source
    self.create(:name =>code, :ip_address => ip, :source => source)
  end

  def self.track_affiliate code, ip
    self.track code, ip, "affiliate_visit"
  end
  
  def self.track_affiliate_conversion code, ip
    self.track code, ip, 'affiliate_conversion'
  end
  
  def self.create_affiliate code
    self.track code, nil, 'affiliate_created'
  end
end
