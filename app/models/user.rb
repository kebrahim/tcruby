class User < ActiveRecord::Base
  extend Enumerize

  attr_accessible :auth_token, :email, :first_name, :last_name, :password, :password_confirmation,
                  :role

  enumerize :role, in: [:demo, :user, :admin]

  has_and_belongs_to_many :chefs
  has_many :chefstats, :through => :chefs
  has_many :picks

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

  # sends a password_reset email to this user
  def send_password_reset
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save!
    UserMailer.password_reset(self).deliver
  end

  # returns true if this user is an admin
  def is_admin
    return :admin.to_s == self.role.to_s
  end

  # returns true if this user is a demo user
  def is_demo_user
    return :demo.to_s == self.role.to_s
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

  # returns a link to this user's team page with the specified label
  def link_to_page_with_label(label)
    return ("<a href='/teams/" + self.id.to_s + "'>" + label + "</a>").html_safe
  end

  def link_to_page_with_first_name
    return link_to_page_with_label(self.first_name)
  end

  def link_to_page_with_full_name
    return link_to_page_with_label(self.full_name)
  end
end
