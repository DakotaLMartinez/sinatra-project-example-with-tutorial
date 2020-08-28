class PostsController < ApplicationController

  # GET: /posts -> index
  get "/posts" do
    @posts = Post.all
    erb :"/posts/index.html"
  end

  # GET: /posts/new -> new
  get "/posts/new" do
    @post = Post.new
    erb :"/posts/new.html"
  end

  # POST: /posts -> create
  post "/posts" do
    # binding.pry
    @post = current_user.posts.build(title: params[:post][:title],content:params[:post][:content])
    if @post.save
      redirect "/posts"
    else
      erb :"/posts/new.html"
    end
  end

  # GET: /posts/5 -> show
  get "/posts/:id" do
    @post = Post.find(params[:id])
    erb :"/posts/show.html"
  end

  # GET: /posts/5/edit -> edit
  get "/posts/:id/edit" do
    erb :"/posts/edit.html"
  end

  # PATCH: /posts/5 -> update
  patch "/posts/:id" do
    redirect "/posts/:id"
  end

  # DELETE: /posts/5 - destroy
  delete "/posts/:id" do
    redirect "/posts"
  end
end
