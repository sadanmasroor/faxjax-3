require 'digest/sha2'


module SaltedHash
  def initial_salt
    salt = ""
    64.times { salt << (i = Kernel.rand(62); i += ((i < 10) ? 48 : ((i < 36) ? 55 : 61 ))).chr }
    salt
  end
  
  
  def gen_salt
    salt=initial_salt
    Kernel.rand(8192).times {salt = Digest::SHA256.hexdigest(salt)}
    salt
  end

  def salted_hash(salt)
    Digest::SHA512.hexdigest("[#{salt}]#{self}")
  end
  
  def hashed_link
    Digest::SHA1.hexdigest("#{DateTime.now.to_s}:#{self}")
  end
  
  def hash_and_salt
    salt = gen_salt
    [salted_hash(salt), salt]
  end
end

class String
  include SaltedHash
end

