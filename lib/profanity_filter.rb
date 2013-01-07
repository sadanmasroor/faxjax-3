class ProfanityFilter
  def self.profane?(str)
    return false if str.nil?
    !self.profane_word(str).nil?
  end

  def self.profane_word(str)
    return nil if str.nil?
                 
    profanity_list = File.open(File.dirname(__FILE__)+"/profanity-list.txt").readlines
    regexp_string = String.new
    profanity_list.each do |profanity|
      regexp_string += "[\s\r\n]"+profanity.strip+"[\s\r\n]|" 
    end
    if Regexp.new(regexp_string.slice(0, regexp_string.length-1)) =~ str+" "
      return $~.to_s.split(/\s/)[0]
    end
    return nil
  end
end

