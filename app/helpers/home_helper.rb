module HomeHelper
  include ApplicationHelper
  include UrlHelper
  include FormHelper
  
  def make_reset_link(request, hashed_link)
    make_link(request, 'reset/' + hashed_link)
  end
  
  class ContactInfo
    PATH = File.expand_path(File.join(Rails.root, "doc", 'contact_info.yaml'))
    
    include TagHelper

    attr_accessor :preamble, :name, :phone_text, :phone, :email_text, :email, :last_modified
    def initialize 
      @preamble = "To contact"
      @name = 'FaxJax, Inc.'
      @phone_text = 'We can also be reached at'
      @phone = '(855) 532-9529 or (855) 5-faxjax'
      @email_text = 'or by email at'
      @email = 'support@faxjax.com'
      @last_modified = Time.now
    end
  
    def self.from_yaml
      File.open(PATH) do |f|  
        YAML::load(f)
      end
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
  
  
    def to_html
      h4 do
        "#{@preamble} #{@name}"
      end +
      para do
        strong {@name}
      end +
      para do
        [@phone_text, @phone, @email_text, mailto(@email)].join(' ') 
      end
    end

    def update_modified
      @last_modified = Time.now
    end
  end

  def contact_info
    ContactInfo.from_yaml.to_html
  end
  
end