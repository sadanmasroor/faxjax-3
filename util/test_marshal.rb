class TestMarshal
  def self.transmogrify(value)
    marshaled = Marshal.dump(value)
    Marshal.restore(marshaled)
  end
end

class TestObject
  attr_accessor :quantity, :status
end

a = TestObject.new
a.quantity = 12
a.status = 1

b = TestMarshal.transmogrify(a)

puts b.quantity.to_s + " : "+ b.status.to_s
