class User < ActiveRecord::Base

  has_one :dashboard, :dependent => :destroy
  has_many :posts, :foreign_key => "user_id", :dependent => :destroy
  has_many :events, :foreign_key => "user_id", :dependent => :destroy
  has_many :reminders, :foreign_key => "user_id", :dependent => :destroy
  has_many :tags, :foreign_key => "user_id", :dependent => :destroy
  has_many :lists, :foreign_key => "user_id", :dependent => :destroy

  # Paperclip
  has_attached_file :photo, :default_url => '/images/default_:style.png', :styles => {
    :thumb=> "30x30#",
    :small  => "50x50#",
    :medium => "150x150>" }
  
  validates_attachment_size :photo, :less_than => 1.megabytes
  validates_attachment_content_type :photo, :content_type => ['image/jpeg', 'image/gif']
  
  attr_accessor :password
  attr_protected :permission_level
  attr_accessible :name, :email, :password, :password_confirmation, :time_zone, :fname, :lname, :photo
  

  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :name,  :presence => true,
                    :length   => { :maximum => 50 },
                    :uniqueness => { :case_sensitive => false }
  validates :email, :presence => true,
                    :format   => { :with => email_regex },
                    :uniqueness => { :case_sensitive => false }
                    
  validates :password,  :presence => true,
                        :confirmation => true,
                        :length => {:within => 6..40}
  
  validates :time_zone, :presence => true
                        
  
  before_save :encrypt_password
  
  has_many :reverse_relationships, :foreign_key => "followed_id",
                                   :class_name => "Relationship",
                                   :dependent => :destroy
                                  
  has_many :relationships, :foreign_key => "follower_id",
                           :dependent => :destroy
  
  has_many :following, :through => :relationships, :source => :followed
                          
  has_many :followers, :through => :reverse_relationships, :source => :follower
  
  
  #Security
  
  # Return true if the user's password matches the submitted password.
  def has_password?(submitted_password)
    encrypted_password == encrypt(submitted_password)
  end
  
  def self.authenticate(email, submitted_password)
    user = find_by_email(email)
    return nil  if user.nil?
    return user if user.has_password?(submitted_password)
  end
  
  def self.authenticate_with_salt(id, cookie_salt)
    user = find_by_id(id)
    (user && user.salt == cookie_salt) ? user : nil
  end
  
  #Friends
  
  def following?(followed)
    relationships.find_by_followed_id(followed)
  end

  def follow!(followed)
    relationships.create!(:followed_id => followed.id, :confirmed => false)
  end
  
  def follow_confirm!(followed)
    relationships.create!(:followed_id => followed.id, :confirmed =>true)
  end

  def unfollow!(followed)
    relationships.find_by_followed_id(followed).destroy
  end
  
  def self.from_users_followed_by(user)
    following_ids = user.following_ids
    where("user_id IN (#{following_ids}) OR user_id = ?", user)
  end
  
  def reset_password
  	self.password = rand(36**15).to_s(36)
  	encrypt_password
  	UserMailer.reset_email(self, password).deliver    
  end

  
  #returns if this is a relationship where both parties have confirmed
  def confirmed_friend(friend)
  	#confirm both relationships exist before testing confirmed value
  	if !relationships.find_by_followed_id(friend).nil? and !friend.relationships.find_by_followed_id(self).nil?
  	
  	  if relationships.find_by_followed_id(friend).confirmed and friend.relationships.find_by_followed_id(self).confirmed
  		  true
  	  else
  		  false
  	  end
  	end 
  end
  
  def confirmed_invite(friend)
  	relationships.find_by_followed_id(friend).confirmed 
  end
  

  
  
  def new
    @user = User.new
  end

  def create!
    @user = User.new(params[:user])
    @user.permission_level = params[:user][:permission_level]
    if @user.save
      redirect_to users_added_url, :notice => "Signed up!"
    else
      render "new"
    end
  end


  def date
    created_at
  end

  private

    def encrypt_password
      self.salt = make_salt unless has_password?(password)
      self.encrypted_password = encrypt(password)
    end

    def encrypt(string)
      secure_hash("#{salt}--#{string}")
    end

    def make_salt
      secure_hash("#{Time.now.utc}--#{password}")
    end

    def secure_hash(string)
      Digest::SHA2.hexdigest(string)
    end
end

