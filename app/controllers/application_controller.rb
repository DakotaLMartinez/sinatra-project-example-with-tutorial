require './config/environment'

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    set :sessions, true
    set :session_secret, ENV["SESSION_SECRET"]
    set :method_override, true
  end

  get "/" do
    erb :welcome
  end

  private 

  def current_user 
    User.find_by_id(session[:id])
  end

  def logged_in?
    !!current_user
  end

end