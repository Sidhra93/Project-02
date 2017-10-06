require 'sinatra'
# require 'sinatra/reloader'
require 'httparty'
require 'pry'
require_relative 'db_config'
require_relative 'models/book'
require_relative 'models/user'
require_relative 'models/discussion'

enable :sessions

helpers do
  def current_user
    User.find_by(id: session[:user_id])
  end

  def logged_in?
    !!current_user
  end

end

# ===================== HOME PAGE ==========================
get '/' do
  @discussions = Discussion.find_by_sql("select distinct book_id from discussions ")
  erb :index
end

# ===================== BOOK SEARCH/DETAILS ========================

get '/browse-books' do
  @books = Book.all.limit(12).shuffle
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
  @count = 0
  @discussions = Discussion.where(book_id: book_id)
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
    @book.image_url = data["volumeInfo"]["imageLinks"]["thumbnail"]
    @book.volume_id = data["id"]
    @book.save
  end
  erb :details
end

# ========================== COMMENT ==========================

post '/comment' do
  discussion = Discussion.new
  discussion.comment = params[:comment]
  discussion.book_id = params[:volume]
  discussion.user_id = current_user.id
  discussion.commented_at = Time.now.utc.asctime
  discussion.save
  redirect "/details?search=#{params[:volume]}"
end

delete '/comment' do
  comment = Discussion.find(params[:id])
  comment.destroy

  redirect "/details?search=#{comment.book_id}"
end

# ======================= LOGIN PAGE ============================

get '/login-page' do
  @book_id = ''
    if params.key?("id")
      @book_id = params[:id]
    end
  erb :login
end

post '/session' do
  user = User.find_by(email: params[:email])

  if user && user.authenticate(params[:password])
    session[:user_id] = user.id
    if params[:book_id] != ''
      redirect "/details?search=#{params[:book_id]}"
    end
    redirect "/"
  else
    @message = "Wrong credentials. Try Again."
    session[:user_id] = nil
    erb :login
  end
end

delete '/session' do
  if logged_in?
    session[:user_id] = nil
    redirect '/'
  else
    "error"
  end
end

post '/register' do
  user = User.new
  user.email = params[:email]
  user.display_name = params[:display_name]
  user.password = params[:password]
  user.save
  @message = "Succesfully registered. You may now Login."
  erb :login
end
