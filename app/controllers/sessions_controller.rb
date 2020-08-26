class SessionsController < ApplicationController
  get '/login' do 
    erb :'/sessions/login'
  end

  post '/login' do 
    # find the user by their email:
    user = User.find_by_email(params[:email])
    # if they typed in the right password then log them in, if not show them the form again
    if user && user.authenticate(params[:password]) 
      session[:id] = user.id
      redirect "/"
    else 
      @error = "Incorrect email or password"
      erb :'/sessions/login'
    end
  end
end