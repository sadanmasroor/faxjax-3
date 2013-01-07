require "nonce"

class NonceStore < ActiveRecord::Base
  DEFAULT_VAL = 'FAXjax'

  def self.create_with_model model, method
    self.create :value => Nonce::Identity.new(model.send(method)) {DEFAULT_VAL}.nonce,
      :model_name => model.class.name,
      :foreign_id => model.id
  end
  
  # return foreign model from NonceStore.value
  def self.find_model_from_value value
    nonce = self.find_by_value value
    klass = Kernel.const_get nonce.model_name
    klass.find nonce.foreign_id
  end
  
  def self.find_by_foreign_model model
    self.find :first, :conditions => ['model_name = ? and foreign_id = ?', model.class.name, model.id]
  end
  
  
  def self.make_from_email email
    self.new :value => Nonce::Identity.new(email) {DEFAULT_VAL}.nonce
  end
  
  def self.find_by_value the_value
    self.find(:first, :conditions => ['value = ? and active = ?', the_value, true])
  end
  
  def deactivate
    self.active = false
    self.save
  end
end
