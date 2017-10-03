require 'sinatra'
require 'sinatra/reloader'
require 'httparty'
require 'pry'

get '/' do
  erb :index
end

get '/browse-books' do
  erb :booksearch
end

get '/books' do
  search = params[:search]
  results = HTTParty.get("https://www.googleapis.com/books/v1/volumes?q=#{search}&key=AIzaSyBUudw0zTl6mN68yErdEUXrqu8-su1DIWk")
  data = results.parsed_response
  @data_array = data["items"]
  erb :books
end
