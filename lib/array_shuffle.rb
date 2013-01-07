class Array
  def shuffle!
    size.downto(1) do |n| 
      push delete_at(rand(n)) 
    end
    self
  end
end
