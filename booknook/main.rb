require 'sinatra'
require 'sinatra/reloader'
require 'httparty'
require 'pry'
require_relative 'db_config'
require_relative 'models/book'

get '/' do
  erb :index
end

get '/browse-books' do
  @books = Book.all.limit(10)
  erb :booksearch
end

get '/books' do
  search = params[:search]
  results = HTTParty.get("https://www.googleapis.com/books/v1/volumes?q=#{search}&key=#{ENV["BOOKS_API_KEY"]}")
  data = results.parsed_response
  @books = data["items"]
  erb :books
end

get '/details' do
  book_id = params[:search]
  if Book.find_by(volume_id: book_id)
    @book = Book.find_by(volume_id: book_id)
  else
    results = HTTParty.get("https://www.googleapis.com/books/v1/volumes/#{book_id}?key=#{ENV["BOOKS_API_KEY"]}")
    data = results.parsed_response
    @book = Book.new
    @book.title = data["volumeInfo"]["title"]
    @book.author = data["volumeInfo"]["authors"].join(", ")
    @book.date_published = data["volumeInfo"]["publishedDate"]
    @book.description = data["volumeInfo"]["description"]
    @book.image_url = data["volumeInfo"]["imageLinks"]["small"]
    @book.volume_id = data["id"]
    @book.save
  end
  erb :details
end
