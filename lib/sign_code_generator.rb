require "array_shuffle"

class SignCodeGenerator
  # lass SignCodeGenerator

  attr_reader :sign_parts

  def initialize
    @counter=0
    @sign_parts = [] 
    @codes={}
    @keys={}
    @work=[]
    @num=('0'..'9').to_a
    @alp=('A'..'Z').to_a + @num
  end

  def factor num, base
    [num/base, num % base]
  end

  def gen_code num
    current=num
    str=[]
    [10, 36, 36, 36, 36].each do |base|
      current, remain = factor current, base
      str << (base == 10 ? @num[remain] : @alp[remain])
    end
    str.join
  end

  def gen_key
    ((rand*(999999999999-100000000000)).round + 100000000000).to_s
  end

  # for use with larger data sets
  def generate_signs(num, start, &blk)
    start.upto(num+start-1) do |current|
      yield gen_code(current), gen_key
    end
  end

  def generate_parts(num, start=1, shuffle = true)
    @limit = num
    @sign_parts = Array.new(num)

    puts "Phase 1 Building and assembling parts (#{start}-#{start+num})"
    @sign_parts.each_index do |ndx|
      @sign_parts[ndx] = [gen_code(ndx+start), gen_key]
    end
    if shuffle
      puts "Phase 2 Shuffling #{num}"
      @sign_parts.shuffle!
    end
  end
end