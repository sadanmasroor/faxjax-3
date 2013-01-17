class ShippingAmount
  PATH = File.expand_path(File.join(Rails.root, "doc", 'shipping_amount.yaml'))
  attr_accessor :amount
  def initialize
    @amount = 997
  end

  def dump_yaml
    begin
      File.open(PATH, "w") do |f|  
        YAML::dump(self, f)
      end

      true
    rescue Exception => e
      $stderr.puts "Un able to write yaml #{e.message}"
      false
    end
  end
  
  def self.from_yaml
    File.open(PATH) do |f|  
      YAML::load(f)
    end
  end
end
