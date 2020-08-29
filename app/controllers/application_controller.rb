require './config/environment'

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    set :sessions, true
    set :session_secret, ENV["SESSION_SECRET"]
    set :method_override, true
    register Sinatra::Flash
  end

  get "/" do
    @posts = Post.all
    erb :"/posts/index.html"
  end

  not_found do
    flash[:error] = "Whoops! Couldn't find that route"
    redirect "/posts"
  end

  private 

  def current_user 
    User.find_by_id(session[:id])
  end

  def logged_in?
    !!current_user
  end

  def redirect_if_not_logged_in
    if !logged_in?
      flash[:error] = "You must be logged in to view that page"
      redirect request.referrer || "/login"
    end
  end

end