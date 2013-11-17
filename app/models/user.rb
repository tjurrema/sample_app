class User < ActiveRecord::Base

  before_create :create_remember_token
  
  def feed
    #This is preliminary. See "Following users" for the full implementation.
    Micropost.where("user_id = ?", id)
  end
  
  #an users can have many microposts
  has_many :microposts, dependent: :destroy
  
  #Relationship between followed en followers
  has_many :relationships, foreign_key: "follower_id", dependent: :destroy
  has_many :followed_users, through: :relationships, source: :followed
  has_many :reverse_relationships, foreign_key: "followed_id",
                                   class_name:  "Relationship",
                                   dependent:   :destroy
  has_many :followers, through: :reverse_relationships, source: :follower
 
  def following?(other_user)
    relationships.find_by(followed_id: other_user.id)
  end

  def follow!(other_user)
    relationships.create!(followed_id: other_user.id)
  end
  
  def unfollow!(other_user)
    relationships.find_by(followed_id: other_user.id).destroy!
  end
  
  def feed
    Micropost.from_users_followed_by(self)
  end
    
  #convert all the emails in lowercase 
  before_save { self.email = email.downcase }
  
  #checks if the name is empty and max length of 50
  validates :name,  presence: true, length: { maximum: 50 }
  
  #checks if the email is probably true and unique
  
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  #for the password
  has_secure_password
  validates :password, length: { minimum: 6 }
    
  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def User.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  private

    def create_remember_token
      self.remember_token = User.encrypt(User.new_remember_token)
    end
end


