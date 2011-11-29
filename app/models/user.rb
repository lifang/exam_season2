# encoding: utf-8
class User < ActiveRecord::Base
#  has_many :user_role_relations,:dependent=>:destroy
#  has_many :roles,:through=>:user_role_relations,:foreign_key=>"role_id"
#  has_many:examinations,:foreign_key=>"creater_id"
#  has_many:papers, :foreign_key=>"creater_id"
#  has_many:orders
#  has_many:feedbacks
#  has_many:proofs
  has_one :category_manage

  default_scope :order=>'users.created_at desc'
  #email_regex=/\A[\w+\.]+@[a-z\d\-.]+\.[a-z]+\z/i
	#name_regex=/[a-zA-Z]{1,20}|[\u4e00-\u9fa5]{1,10}/

	#telephone_regex=/^[1-9]\d*$/
  attr_accessor :password,:old_password
  #	attr_accessible :name,:username,:mobilephone,:address,:email,:password,:password_confirmation,:status
  #	validates:name,  :presence=>true,:format=>{:with=>name_regex},:length=>{:maximum=>30}
  #	validates:email,  :presence=>true,:uniqueness =>true,:format=>{:with=>email_regex},:length=>{:maximum=>50}
  validates:password, :confirmation=>true,:length=>{:within=>6..20}, :allow_nil => true

  STATUS = {:LOCK => 0, :NORMAL => 1} #0 未激活用户  1 已激活用户
  
  DEFAULT_PASSWORD = "123456"

	def right_password?(varnum)
    self.encrypted_password==encrypt(varnum)
  end

  #创建用户权限
  def set_role(role)
    roles << role
  end
  
  def has_password?(submitted_password)
		encrypted_password == encrypt(submitted_password)
	end

  def self.authenticate(username, submitted_password)
    user = find_by_username(username)
    return nil if user.nil?
    return user if user.has_password?(submitted_password)
  end

  
  def encrypt_password
    self.encrypted_password=encrypt(password)
  end

  #考试组织人员添加考生自动添加账号
  def self.auto_add_user(name, username, email, mobilephone)
    user = User.new(:name => name, :username => username, :email => email,
      :mobilephone => mobilephone,:password => DEFAULT_PASSWORD,:password_confirmation => DEFAULT_PASSWORD)
    user.set_role(Role.find(Role::TYPES[:STUDENT]))
    user.status = User::STATUS[:NORMAL]
    user.encrypt_password
    user.save!
    return user
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



