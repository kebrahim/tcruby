class User < ActiveRecord::Base
  extend Enumerize

  attr_accessible :auth_token, :email, :first_name, :last_name, :password, :password_confirmation,
                  :role

  enumerize :role, in: [:demo, :user, :admin]

  has_and_belongs_to_many :chefs

  attr_accessor :password
  before_save :encrypt_password
  before_create { generate_token(:auth_token) }

  validates_confirmation_of :password
  validates_presence_of :password, :on => :create
  validates_presence_of :password_confirmation, :on => :create
  validates_presence_of :email
  validates_uniqueness_of :email, :case_sensitive => false
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :role

  ALL_ROLES_ARRAY = [:demo, :user, :admin]

  def self.authenticate(email, password)
    user = find_by_email(email)
    if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
      user
    else
      nil
    end
  end
  
  def encrypt_password
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end

  # Returns the full name of the user
  def full_name
    return self.first_name + " " + self.last_name
  end

  # Overrides find_by_email to provide case-insensitive search, useful for logging in.
  def self.find_by_email(email)
    User.find(:all, :conditions => ["lower(email) = lower(?)", email]).first
  end

  # returns true if this user is an admin or super-admin
  def is_admin
    return :admin.to_s == self.role
  end

  # returns the role associated with this user's role string
  def role_type
    return User.role_type_from_string(self.role)
  end

  # returns the role associated with the specified role string
  def self.role_type_from_string(role_string)
    ALL_ROLES_ARRAY.each { |role|
      if role.to_s == role_string
        return role
      end
    }
    return nil
  end
end
