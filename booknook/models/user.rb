class User < ActiveRecord::Base
  has_many :discussions
  has_secure_password
end
