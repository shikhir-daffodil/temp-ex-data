class User < ActiveRecord::Base
  attr_accessor :password
  validates :name, :presence => true, :uniqueness => true, :length => { :in => 4..50 }
  validates :email, :presence => true, :uniqueness => { case_sensitive: false }, on: :tryedit
  validates :email, :presence => true, :uniqueness => { case_sensitive: false }
  validates :phone, format: { with: /\d[0-9]\)*\z/, message: "Number Invalid" }, :length => { :in => 4..10 }
  validates :experience, :presence => true
  validates :password, :confirmation => true , on: :create
  validates_length_of :password, :in => 4..20
  
  before_save :encrypt_password
  after_save :clear_password
  def encrypt_password
    if password.present?
      self.salt = Digest::SHA1.hexdigest("#{email}#{Time.now}")
      self.encrypted_password= Digest::SHA1.hexdigest("#{salt},#{password}")
    end
  end
  def clear_password 
    self.password = nil
  end
  #----------------------------------- Login
  def self.authenticate(email="", login_password="")
    user = User.find_by_email(email)
    if user && user.match_password(login_password)
      return user
    else
      return false
    end
  end
  def match_password(login_password="")
    if encrypted_password == Digest::SHA1.hexdigest("#{salt},#{login_password}")
      return true
    else
      return false
    end
  end
end
