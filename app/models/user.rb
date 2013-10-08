class User < ActiveRecord::Base
  attr_accessible :auth_token, :email, :first_name, :last_name, :password_hash, :password_salt, :role
end
