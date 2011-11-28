class User < ActiveRecord::Base
  has_many :user_role_relations,:dependent=>:destroy
  has_many :roles,:through=>:user_role_relations,:foreign_key=>"role_id"
  attr_accessor :password
  validates:password, :confirmation=>true,:length=>{:within=>6..20}, :allow_nil => true


  def has_password?(submitted_password)
		encrypted_password == encrypt(submitted_password)
	end
  
  def encrypt_password
    self.encrypted_password=encrypt(password)
  end

  private
  def encrypt(string)
    self.salt = make_salt if new_record?
    secure_hash("#{salt}--#{string}")
  end

  def make_salt
    secure_hash("#{Time.new.utc}--#{password}")
  end

  def secure_hash(string)
    Digest::SHA2.hexdigest(string)
  end
end
