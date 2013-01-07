require "salted_hash"


class User < ActiveRecord::Base
  has_many :signs
  has_many :listings, :dependent => :destroy
  has_many :messages
  has_one :user_prefs, :dependent => :destroy

  before_destroy :reset_signs

  validates_presence_of     :name, :email , :first_name

  validates_uniqueness_of   :email

  validates_length_of       :name,
                            :within => 5..16,
                            :message => "must be between 5 and 16 characters long"

  validates_length_of     :password,
                          :minimum => 5
                            
  before_create :set_password
  def set_password
    self.password, self.salt = self.password.hash_and_salt
  end

  attr_accessor             :password_confirmation

  #  generate and store hashed link for this user
  #  used to generate password reset link
  def gen_hashed_link
    self.hashed_link = self.email.hashed_link
    self.password_confirmation = self.password
    self.save
    self.hashed_link
  end

  def reset_password
    unless self.valid?
      self.password = self.password_confirmation = nil
      return false
    end
    set_password
    self.password_confirmation = self.password
    self.hashed_link = nil
    self.save
  end

  def validate_password
    errors.add :password, "can't be blank" if self.password.blank?
    errors.add_to_base "passwords must match" if self.password_confirmation != self.password
  end
  
  

  def validate
    validate_uniqueness_of_name
    if !email.nil? && !email_address_valid?
      errors.add(:email, "is not a valid address")
    end
    if !has_read_tos
      errors.add_to_base("You must accept the Terms & Conditions to sign up")
    end
    validate_password
  end
  
  def validate_uniqueness_of_name
    baseClass = self.class
    begin
      while not baseClass.superclass.nil? and baseClass.superclass.new.send("login")
        baseClass=baseClass.superclass
      end
    rescue
    end
    found_instance = baseClass.find(:all,:conditions => ["name = ?", self.name])
    errors.add("name", "must be unique") if found_instance.size > 0 and not found_instance[0].id == self.id
  end

  def validate_on_create
    # errors.add(:password, "can't be blank") if self.password.nil? || self.password.empty?
    # if !self.password.nil?
    #   errors.add(:password, "must be 5-16 characters long") if self.password.length < 5 or self.password.length > 16
    # end
    # errors.add(:password_confirmation, "can't be blank") if self.password_confirmation.nil? || self.password_confirmation.empty?
    # errors.add_to_base("Passwords must match") if self.password_confirmation != self.password
  end

  def validate_on_update
    errors.add(:password, "can't be blank") if password.nil? || password.empty?
    if !password.nil? && !password.empty?
      user = User.find(id)
      # if user.password != password
      #   errors.add(:password, "must be at least 5 characters long") if password.length < 5
      #   errors.add(:password_confirmation, "can't be blank") if password_confirmation.nil? || password_confirmation.empty?
      #   errors.add_to_base("Passwords must match") if password_confirmation != password
      # end
    end
  end

  def unused_signs
    unused_signs = []
    signs.each do |sign|
      unused_signs << sign if sign.listing.nil?
    end
    unused_signs
  end

  def unused_non_expired_signs
    unused_signs = []
    signs.each do |sign|
      unused_signs << sign if sign.listing.nil? && !sign.expired?
    end
    unused_signs
  end

  def messages
    Message.find(:all, :conditions => ["user_id = ? AND deleted_on IS NULL", self.id], :order => "created_on DESC")
  end
  
  def unread_messages
    Message.find(:all, :conditions => ["user_id = ? AND read_on IS NULL AND deleted_on IS NULL", self.id], :order => "created_on DESC")
  end

  def sent_messages
    Message.find(:all, :conditions => ["from_user_id = ?", self.id], :order => "created_on DESC")
  end

  def contacts
    contacts = []
    hash = {}
    arr = User.find_by_sql ["SELECT DISTINCT * FROM users JOIN messages ON messages.from_user_id = users.id WHERE messages.user_id = ?", self.id]
    arr.each do |user|
      if hash[user.id].nil?
        contacts << user
        hash[user.id] = true
      end
    end
    arr = User.find_by_sql ["SELECT DISTINCT * FROM users JOIN messages ON messages.user_id = users.id WHERE messages.from_user_id = ?", self.id]
    arr.each do |user|
      if hash[user.id].nil?
        contacts << user
        hash[user.id] = true
      end
    end
    contacts
  end

  def email_address_with_name
    "\"#{first_name} #{last_name}\" <#{email}>"
  end

  def email_address_valid?() email =~ /\w[-.\w]*\@[-\w]+[-.\w]*\.\w+/ end

  def self.login(name, password)
    user = self.find_by_name(name)
    if user
      if user.password != password.salted_hash(user.salt)
        user = nil
      end
    end
    user
  end

  def self.find_by_hashed_link(link)
    find(:all,:conditions => ["hashed_link = ?", link])[0]
  end

  # PRIVATE
  private

  def reset_signs
    self.signs.each do |sign|
      Sign.reset(sign.id)
    end
  end
end

class Administrator < User
  
end
