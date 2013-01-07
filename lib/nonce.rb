require "digest/sha2"
require "base64"


module Nonce
  
  #  generates a random string of random length <= 64 chars
  #  used to perturb the string through every round in compute
  # used if no block passed to initializers
  DEFAULT_PERTURBATION_FN = lambda do
    str = ''
    (rand(Time.now.sec+3)+1).times do
        str << (i = Kernel.rand(62); i += ((i < 10) ? 48 : ((i < 36) ? 55 : 61 ))).chr
    end
    str
  end
  
  class Base
    attr_reader :nonce, :range
    @block=nil
    def initialize range=0..-4, &blk
      @block = blk
      @range = range
      compute
    end
    
    def pertubation_fn
      @block || DEFAULT_PERTURBATION_FN
    end
    
    # override in derived classes
    def compute
      @nonce=Base64.encode64(Digest::SHA1.hexdigest(pertubation_fn.call))[@range]
    end
  end
  
  class Identity < Base
    def initialize identity, range=5..30, &blk
      @identity = identity
      super(range, &blk)
    end
    
    def compute
      str = "#{@identity}##{Time.now.to_i}"
      rand(8192).times do
        str = Digest::SHA1.hexdigest(str+"##{pertubation_fn.call}")
      end
      @nonce=Base64.encode64(str)[@range]
    end
  end
end
