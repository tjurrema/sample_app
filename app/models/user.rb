class User < ActiveRecord::Base
  #convert all the emails in lowercase 
  before_save { self.email = email.downcase }
  
  #checks if the name is empty and max length of 50
  validates :name,  presence: true, length: { maximum: 50 }
  
  #checks if the email is probably true and unique
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  #for the password
  has_secure_password
  validates :password, length: { minimum: 6 }
end


