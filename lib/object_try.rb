class Object
  def try method, *args, &blk
    send(method, *args, &blk) unless self.nil?
  end
end