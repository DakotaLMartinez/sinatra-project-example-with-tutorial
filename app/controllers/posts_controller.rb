class PostsController < ApplicationController

  # GET: /posts -> index
  get "/posts" do
    @posts = Post.all
    erb :"/posts/index.html"
  end

  # GET: /posts/new -> new
  get "/posts/new" do
    redirect_if_not_logged_in
    @post = Post.new
    erb :"/posts/new.html"
  end

  # POST: /posts -> create
  post "/posts" do
    redirect_if_not_logged_in
    @post = current_user.posts.build(title: params[:post][:title], content: params[:post][:content])
    if @post.save
      redirect "/posts"
    else
      erb :"/posts/new.html"
    end
  end

  # GET: /posts/5 -> show
  get "/posts/:id" do
    set_post
    erb :"/posts/show.html"
  end

  # GET: /posts/5/edit -> edit
  get "/posts/:id/edit" do
    set_post
    redirect_if_not_authorized
    erb :"/posts/edit.html"
  end

  # PATCH: /posts/5 -> update
  patch "/posts/:id" do
    set_post
    redirect_if_not_authorized
    if @post.update(title: params[:post][:title], content: params[:post][:content])
      flash[:success] = "Post successfully updated"
      redirect "/posts/#{@post.id}"
    else 
      erb :"/posts/edit.html"
    end
  end

  # DELETE: /posts/5 - destroy
  delete "/posts/:id" do
    set_post
    redirect_if_not_authorized
    @post.destroy
    redirect "/posts"
  end

  private 

  def set_post 
    @post = Post.find_by_id(params[:id])
    if @post.nil?
      flash[:error] = "Couldn't find a Post with id: #{params[:id]}"
      redirect "/posts"
    end
  end

  def redirect_if_not_authorized
    redirect_if_not_logged_in
    if !authorize_post(@post)
      flash[:error] = "You don't have permission to do that action"
      redirect "/posts"
    end
  end

  def authorize_post(post)
    current_user == post.author
  end

end
