#  convert_five_code.rb
#  Returns a 5 digit code from a 4 charcter one

class ConvertFiveCode
  attr_accessor :ends
  def initialize
    @ends = ('A'..'Z').to_a + ('0'..'9').to_a
  end
  
  def code5 code4
    code4 + @ends[rand(36)]
  end
  
  def cvt sign
    p "A> #{sign.code}"
    listings = Listing.find_by_code sign.code
    raise RuntimeError.new('missing sign code') if listings.nil?
    raise RuntimeError.new 'Multiple listings per sign' if listings.length != 1
    listing = listings.first
    sign.code = code5 sign.code
    listing.sign_code = sign.code
    [sign, listing]
  end
  
end