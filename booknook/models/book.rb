class Book < ActiveRecord::Base
  has_many :discussions
end
