class ApplicationConfig < ActiveRecord::Base
 	def self.get_config
    ApplicationConfig.find(1)
 	end
end
