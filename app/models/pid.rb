class Pid < ActiveRecord::Base
  include Listable
  
  belongs_to :user
end
