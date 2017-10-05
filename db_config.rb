require 'active_record'

options = {
  adapter: "postgresql",
  database: "booknook",
  username: "sidhra"
}


ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'] || options)
