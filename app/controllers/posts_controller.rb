class PostsController < ApplicationController

  # GET: /posts
  get "/posts" do
    erb :"/posts/index.html"
  end

  # GET: /posts/new
  get "/posts/new" do
    erb :"/posts/new.html"
  end

  # POST: /posts
  post "/posts" do
    redirect "/posts"
  end

  # GET: /posts/5
  get "/posts/:id" do
    erb :"/posts/show.html"
  end

  # GET: /posts/5/edit
  get "/posts/:id/edit" do
    erb :"/posts/edit.html"
  end

  # PATCH: /posts/5
  patch "/posts/:id" do
    redirect "/posts/:id"
  end

  # DELETE: /posts/5
  delete "/posts/:id" do
    redirect "/posts"
  end
end
