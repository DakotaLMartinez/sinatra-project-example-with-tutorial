## Authentication in Sinatra

In order to implement Authentication in Sinatra, we're going to need to address the following tasks:
1. Enable the rack session cookie middleware. 
2. Generate a session secret so that our cookies are securely encrypted. 
3. Create a `User` model that stores an email/username and encrypted password
4. implement the `has_secure_password` macro in the `User` model to enable storing an encrypted version of the password and authenticating against that.
5. Build forms for sign up and log in and links to the routes that render them
6. Build out controllers that handle rendering forms and responding to their submission
7. Use the methods from `has_secure_password` to create user accounts and authenticate them later, storing the user's ID in session cookies using the `session` hash in our controllers.

### Dependencies (Gems/packages)
- (✔) 'activerecord'
- (✔) 'bcrypt'
- (✔) 'dotenv'
- (✔) 'session_secret_generator'
### Configuration (environment variables/other stuff in config folder)
- (✔) enable sessions in the controller
- (✔) set session secret in controller to `ENV['SESSION_SECRET']`
- (✔) create `SESSION_SECRET` in a file called `.env` 
- (✔) load the varibles in the `.env` file using `Dotenv.load` in `config/environment`. 
- (✔) to test this is working, open `bundle exec tux` and type in `ENV['SESSION_SECRET']` You should see the value inside of the `.env` file. 
- eventually we'll have to load our 2 controllers within the `config.ru` file as well
- (✔) we'll need to add the `method_override` so that we're able to send a delete request for `/logout`
### Database
- (✔) Users table with a column `password_digest` and some other column to find a user by (email or username)
### Models
- (✔) User model that inherits from `ActiveRecord::Base` and invokes the `has_secure_password` macro.
### Controllers
- `SessionsController` for logging in and out
- (✔) `UsersController` for creating new accounts
### Routes
- `get '/login'` for rendering the log in form
- `post '/login'` for handling the log in form submission
- `delete '/logout` for handling a logout button click.
- (✔) `get '/users/new'` for rendering the registration form
- (✔) `post '/users` for handling the registration form submission.
### Views
- (✔) view with registration form for creating a new account
- view with login form for logging into an existing account
- navigation links in `layout.erb` for authenication (conditional logic for displaying a logout button)


## How to Follow along

```
corneal new authentication_codealong
```

add to Gemfile:
```ruby
group :development, :test do 
  gem 'dotenv'
  gem 'session_secret_generator'
end
```
run 
```
bundle install
```
Create  a file in the root of our project called `.env`

```
SESSION_SECRET=
```

now in your terminal, run

```
generate_secret
```
paste the output into your `.env` file after the `=` sign, like so:

```
SESSION_SECRET=3688fd1c5e985597198a7d918d6933994356f4ae232dae625e7f8f83228378f786d61c9fc778cc4cf823f2e09e11c5ed18eac69049de217eb32dd5c81e0f74f7
```
**Don't use the same one as I have here!!!**

Remember to add your `.env` file to a file called `.gitignore` so that it's not tracked in git. Create a file in the root of your project called `.gitignore` and put the following line in it:

```
.env
```

After we've added the .env file to our project and made sure it's not in version control, we can load the environment variable (SESSION_SECRET) into our app, by using the `dotenv` gem's `Dotenv.load` method within our `config/enironment.rb` file.

```ruby
# config/environment.rb
ENV['SINATRA_ENV'] ||= "development"

require 'bundler/setup'
Bundler.require(:default, ENV['SINATRA_ENV'])

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => "db/#{ENV['SINATRA_ENV']}.sqlite"
)

Dotenv.load

require './app/controllers/application_controller'
require_all 'app'

```

To test this out and make sure that it works, we want to run `bundle exec tux` from our terminal and to type in `ENV['SESSION_SECRET]`. If this worked properly, then we should see the value that's stored inside the `.env` file.

Configuring our controller to use sessions and our session secret and also enabling the rack method override middleware so we can use the hidden input trick to send PUT, PATCH, and DELETE requests later on:

```ruby
# app/controllers/application_controller.rb
require './config/environment'

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    set :sessions, true
    set :session_secret, ENV["SESSION_SECRET"]
  end

  get "/" do
    erb :welcome
  end

end

```

After configuring our controller, let's build out our `User` model and `users` table:

```
corneal model User email:string password_digest:string
```

Next, run 

```
rake db:migrate
```

Finally, in the `User` model, let's invoke the `has_secure_password` macro:

```ruby
class User < ActiveRecord::Base
  has_secure_password
end
```

## Has Secure Password
has_secure_password important methods:
- `password=(password)` this method takes an argument of a password (unencrypted) and uses it to create a new hashes and salted (encrypted) password which is an instance of the `BCrypt::Password` class.
- `authenticate(test_password)` extracts the salt from the stored (encrypted) password and uses it to create a new password using `test_password` if those are the same it returns the user (truthy) and if they're not it returns `false`

`password=` gets called when you create a new user:
```ruby
User.new(email: params[:email], password: params[:password])
```

## Creating our Controllers and Routes for Registration

Create a file called `users_controller.rb` and add the following content:

```ruby
# app/controllers/users_controller.rb
class UsersController < ApplicationController 

  get '/users/new' do 
    # render the form to create a user account
    erb :'/users/new'
  end 

  post '/users' do 

  end
end
```

We also need to make sure that our Sinatra app knows to use this controller to respond to incoming requests. To do that we'll have to add a line to the bottom of our `config.ru` file:

```ruby
# config.ru
require './config/environment'

if ActiveRecord::Migrator.needs_migration?
  raise 'Migrations are pending. Run `rake db:migrate` to resolve the issue.'
end

run ApplicationController
use UsersController
```

To try this out in the browser, we'll also need a view to render the form. Create a folder app/views/users and then a file inside of it called new.erb:

```html
<!-- app/views/users/new.erb -->
<h1>Sign Up</h1>
<form method="post" action="/users">
  <p>
    <div><label for="email">Email</label></div>
    <input type="email" name="email" id="email" />
  </p>
  <p>
    <div><label for="password">Password</label></div>
    <input type="password" name="password" id="password" />
  </p>
  <input type="submit" value="Sign Up"/>
</form>
```

Let's update our controller to handle the form submission:

```ruby
# app/controllers/users_controller.rb
class UsersController < ApplicationController 

  get '/users/new' do 
    # render the form to create a user account
    erb :'users/new'
  end 

  post '/users' do 
    @user = User.new(email: params[:email], password: params[:password])
    if @user.save
      session[:id] = @user.id
      redirect "/"
    else 
      erb :'users/new'
    end
  end
end
```

## Creating our Controllers and Routes for Login

1. Create a `sessions_controller.rb` file
2. Add `use SessionsController` to the bottom of `config.ru`
3. Add routes to render the login form and handle the submission
4. Add login view template.

```ruby
# app/controllers/sessions_controller.rb
class SessionsController < ApplicationController
  get '/login' do 
    erb :'/sessions/login'
  end

  post '/login' do 

  end
end
```

Create a views directory for sessions: `app/views/sessions` inside the folder we create a template for the login form: `login.erb`

```html
<!-- app/views/sessions/login.erb -->
<h1>Log In</h1>
<%= @error %>
<form method="post" action="/login">
  <p>
    <div><label for="email">Email</label></div>
    <input type="email" name="email" id="email" />
  </p>
  <p>
    <div><label for="password">Password</label></div>
    <input type="password" name="password" id="password" />
  </p>
  <input type="submit" value="Sign In"/>
</form>
```

Then we need to fill in our controller to handle the form submission:

```ruby
# app/controllers/sessions_controller.rb
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
```

## Adding Logout functionality

First, we'll add navigation so we can get to the sign up and log in pages:

```
<nav>
  <a href="/login">Log In</a>
  <a href="/users/new">Sign Up</a>
</nav>
```
So the layout file should look something like this:

```html
<!-- app/views/layout.erb -->
<!DOCTYPE html>
<!--[if lt IE 7]> <html class="no-js ie6 oldie" lang="en"> <![endif]-->
<!--[if IE 7]>    <html class="no-js ie7 oldie" lang="en"> <![endif]-->
<!--[if IE 8]>    <html class="no-js ie8 oldie" lang="en"> <![endif]-->
<!--[if gt IE 8]><!--> <html class="no-js" lang="en"> <!--<![endif]-->
  <head>
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge, chrome=1" />

    <title>Authentication</title>

    <meta name="viewport" content="width=device-width, initial-scale=1.0" />

    <link rel="stylesheet" href="/stylesheets/main.css" />
  </head>
  <body>
    <div class="wrapper">
      <nav>
        <a href="/login">Log In</a>
        <a href="/users/new">Sign Up</a>
      </nav>
        <%= yield %>

      <footer class="branding">
        <small>&copy; 2020 <strong>Authentication</strong></small>
      </footer>
    </div>

    <script src="http://ajax.googleapis.com/ajax/libs/jquery/1/jquery.min.js"></script>
    <!--[if lt IE 7]>
      <script src="//ajax.googleapis.com/ajax/libs/chrome-frame/1.0.2/CFInstall.min.js"></script>
      <script>window.attachEvent("onload",function(){CFInstall.check({mode:"overlay"})})</script>
    <![endif]-->
  </body>
</html>

```

We next want to add in conditional logic to display a logout link if we're logged in and display links to sign in and sign up, if we're not logged in.  

**How do we know if someone is logged in or not?**
their user ID is in the session:
```ruby
session[:id] = user.id
```

If we add a private method to our ApplicationController, it will be accessible within all of our routes defined in controllers that inherit from ApplicationController and also therefore the associated views. So, we can define a method called `current_user` that will return the currently logged in user if there is one, and `nil` if there isn't. This will allow us to introduce conditional logic in the view to display different content to logged in users. We can also define another method called `logged_in?` if we want to return true or false.

```ruby
# app/controllers/application_controller.rb
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
```

For the view, we'll add the conditional logic:

```html
<nav>
  <% if !logged_in? %>
    <a href="/login">Log In</a>
    <a href="/users/new">Sign Up</a>
  <% else %>
    <form method="post" action="/logout">
      <input type="hidden" name="_method" value="delete" />
      <input type="submit" value="Log Out" />
    </form>
  <% end %>
</nav>
```

We need to add a route to our SessionsController to handle logging out:

```ruby
  delete '/logout' do 
    session.clear
    redirect "/"
  end
```
## Understanding Sessions vs Cookies

Cookies are small text files stored in the browser. They are tagged with the domain that issued them and generally encrypted so they can't be tampered with. Cookies are sent along with subsequent requests made to the domain that issued them. Data shouldn't be editable by the user in the browser. So, this means a user can't go in and edit the user_id in their cookie to pretend to be logged in as somebody else.

The `session` hash is our interface for reading from and writing data to signed and encrypted cookies sent with requests from the browser to the server and back with the response.



## Finish out the Project Requirements

- Build an MVC Sinatra application.
- Use ActiveRecord with Sinatra.
- Use multiple models.
- Use at least one has_many relationship on a User model and one belongs_to relationship on another model.
- Must have user accounts - users must be able to sign up, sign in, and sign out.
- Validate uniqueness of user login attribute (username or email).
- Once logged in, a user must have the ability to create, read, update and destroy the resource that belongs_to user.
- Ensure that users can edit and delete only their own resources - not resources created by other users.
- Validate user input so bad data cannot be persisted to the database.
- BONUS: Display validation failures to user with error messages. (This is an optional feature, challenge yourself and give it a shot!)

### Instructions
Create a new repository on GitHub for your Sinatra application.
When you create the Sinatra app for your assessment, add the spec.md file from this repo to the root directory of the project, commit it to Git and push it up to GitHub.
Build your application. Make sure to commit early and commit often. Commit messages should be meaningful (clearly describe what you're doing in the commit) and accurate (there should be nothing in the commit that doesn't match the description in the commit message). Good rule of thumb is to commit every 3-7 mins of actual coding time. Most of your commits should have under 15 lines of code and a 2 line commit is perfectly acceptable.
While you're working on it, record a 30 min coding session with your favorite screen capture tool. During the session, either think out loud or not. It's up to you. You don't need to submit the video, but we may ask for it at a later time.
Make sure to create a good README.md with a short description, install instructions, a contributor's guide, and a link to the license for your code. https://www.makeareadme.com/
Make sure to check each box in your spec.md (replace the space between the square braces with an x) and explain next to each one how you've met the requirement before you submit your project.
Prepare a short video demo with narration describing how a user would interact with your working application.
Write a blog post about the project and process.
When done, submit your GitHub repo's URL, a link to your video demo, and a link to your blog post in the corresponding text boxes in the right rail. Hit "I'm done" to wrap it up.

To fulfill the technical requirements, we'll use the 7 layers again  to plan our 2nd day of work. To keep this example generic, we're going to build out a simple blog where users can create read update and destroy posts. They can only update and destroy posts that they created.

### Dependencies (Gems/packages)
nothing new required here (we already have activerecord and sinatra and our required dependencies for authentication)
### Configuration (environment variables/other stuff in config folder)
config.ru needs to `use` our new controller `PostsController`
### Database
- Add a posts table with 3 columns: title:string, content:text author_id:integer
### Models
- Add a `Post` model that `belongs_to` an author (a User)
### Views
- Add an index view to show a list of posts with links to the full post
- Add a show view to display a full post
- Add a new view that will display the form to create a new post
- Add an edit view that will display the form allowing us to update an existing post
### Controllers
- Add a `PostsController`
### Routes
- get '/posts' -> index of posts
- get '/posts/new' -> form to create new post
- post '/posts' -> handle new post form submission
- get '/posts/:id' -> detail page for post
- get '/posts/:id/edit' -> form to edit existing post (only viewable by author of post)
- patch '/posts/:id' -> handle edit post form submission (only editable by author of post)
- delete '/posts/:id' -> handle deleting a particular post (only deletable by author of post)

To generate a bunch of these files and get started, we can use corneal. Corneal has a help function that allows you to see all of your options. 

```
corneal help
```
Here are our options:
```
Commands:
  corneal -v               # Show Corneal version number
  corneal controller NAME  # Generate a controller
  corneal help [COMMAND]   # Describe available commands or one specific command
  corneal model NAME       # Generate a model
  corneal new APP_PATH     # Creates a new Sinatra application
  corneal scaffold NAME    # Generate a model with its associated views and controllers
```

The one we want here is the scaffold generator, this will create a model, migration, controller and views. It will also add the controller to the config.ru file. If we pass additional arguments after the name of the model, we can user the generator to add columns to our migration as well. The default column type is string, if we want another type, we can add a colon after the name of the column to specify the type. For example, content:text, author_id:integer.

In our case we can run:

```
corneal scaffold Post title content:text author_id:integer
```
This will print something like this to the terminal:
```
create  app/models/post.rb
create  db/migrate/20200827232626_create_posts.rb
create  app/controllers/posts_controller.rb
insert  config.ru
create  app/views/posts
create  app/views/posts/edit.html.erb
create  app/views/posts/index.html.erb
create  app/views/posts/new.html.erb
create  app/views/posts/show.html.erb
```
Tasks

We need to associate Users and Posts. 

```ruby
class Post < ActiveRecord::Base
  belongs_to :author, class_name: "User" 
  # adding class_name: "User" here tells activerecord to find a User instance associated with a post we call this method on, not an Author instance. The foreign key :author_id is inferred from the fact that we have belongs_to :author here. If the foreign key were something else, we'd also have to add foreign_key: "something_else_id" here.
end

class User < ActiveRecord::Base
  has_secure_password
  validates :email, presence: true, uniqueness: true
  has_many :posts, foreign_key: "author_id"
  # the foreign key would be assumed to be user_id because has_many is invoiked within the User class. Because our foreign key is actually author_id, we need to specify that in the option passed to has_many.
end
```

To Add in index, we need to get all the Posts and then we can iterate over them in the corresponding view:

```
  # GET: /posts
  get "/posts" do
    @posts = Post.all
    erb :"/posts/index.html"
  end
```

```
<h1>This is the Model's index page.</h1>
<% @posts.each do |post| %>
<p><a href="/posts/<%= post.id %>"><%= post.title %></a></p>
<% end %>
```

For show we need to find a post using the id coming through the params hash (that's captured by the dynamic route) and then we can show the details in the show.html.erb view template.

```
  # GET: /posts/5
  get "/posts/:id" do
    @post = Post.find(params[:id])
    erb :"/posts/show.html"
  end
```

```
<h1><%= @post.title %></h1>
<p><%= @post.author.email %></p>
<p><%= @post.content %></p>
```



When we're building a form

## Important understanding for Assessment

**What determines where the browser sends a request upon submission?**

method and action attribute values
method is the http verb
action is the path it's sent to.

**What determines the keys in the params hash that appear in the controller upon form submission?**

The value of the `name` attributes in your form inputs.


When we add our form it'll look something like this:

```html
<h1>New Post</h1>
<form method="post" action="/posts">
  <p>
    <div><label for="title">Title</label></div>
    <input id="title" type="text" name="post[title]" />
  </p>
  <p>
    <div><label for="content">content</label></div>
    <textarea rows="8" cols="45" id="content" type="text" name="post[content]"></textarea>
  
  </p>
  <input type="submit" value="Create Post" />
</form>
```

The corresponding controller should look like this:

```
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

```

In the view, we can handle displaying errors by copying this code from the railsguides for ActiveRecord Validations:

```
<% if @article.errors.any? %>
  <div id="error_explanation">
    <h2><%= pluralize(@article.errors.count, "error") %> prohibited this article from being saved:</h2>
 
    <ul>
    <% @article.errors.full_messages.each do |msg| %>
      <li><%= msg %></li>
    <% end %>
    </ul>
  </div>
<% end %>
```
We'll want to replace @article with @post in our case, and the pluralize method should be removed and replaced with something like this:

```
<h2><%= @post.errors.count %> error(s) prohibited this post from being saved:</h2>
```

## Adding an Edit Form
To add an edit form to our application, we can use our new form as a template because of the choices we've made about displaying errors and making sure the values for our inputs reflect the values stored in our `@post` instance variable.

So, we can copy our new.html.erb file into edit.html.erb and make just a couple of small changes:

1. We need to change our header to "Edit Post"
2. We need to add a methodoverride input to our form to send a patch request instead of a post request
3. Change submit button value to `Update Post`
4. We need to update the form action so that it makes a request to the update route.

```html
<h1>Edit Post</h1>

<% if @post.errors.any? %>
  <div id="error_explanation">
    <h2><%= @post.errors.count %> error(s) prohibited this post from being saved:</h2>
 
    <ul>
    <% @post.errors.full_messages.each do |msg| %>
      <li><%= msg %></li>
    <% end %>
    </ul>
  </div>
<% end %>
<form method="post" action="/posts/<%= @post.id %>">
  <input type="hidden" name="_method" value="patch" />
  <p>
    <div><label for="title">Title</label></div>
    <input id="title" type="text" name="post[title]" value="<%= @post.title %>" />
  </p>
  <p>
    <div><label for="content">content</label></div>
    <textarea rows="8" cols="45" id="content" type="text" name="post[content]"><%= @post.content %></textarea>
  
  </p>
  <input type="submit" value="Update Post" />
</form>
```

## Adding Error handling for when we don't find a record
If we hit an issue where a record is not found using `Post.find_by_id` we can add a method that finds the record and redirects with an error message if the record is not found. In order to display a message after a redirect we need to add some middleware that will allow us to write to cookies some data that will persist for a single request/response cycle and then be cleared.

To do this, there is a gem called `sinatra-flash` which will allow us to add this functionality.

in our Gemfile, let's add:

```ruby
gem 'sinatra-flash'
```

After adding this to the gemfile, run 
```
bundle install
```

Next, we want to register `Sinatra::Flash` in our controller configuration

```ruby
# app/controllers/application_controller.rb
configure do
  set :public_folder, 'public'
  set :views, 'app/views'
  set :sessions, true
  set :session_secret, ENV["SESSION_SECRET"]
  set :method_override, true
  register Sinatra::Flash
end
```

Finally, we want to add the `styled_flash` view helper to our `layout.erb` file, so we can use flash messages to display text to our users after redirects throughout the application.

```
<%= styled_flash %>
```

So our `layout.erb` file looks like this: 

```html
<!DOCTYPE html>
<!--[if lt IE 7]> <html class="no-js ie6 oldie" lang="en"> <![endif]-->
<!--[if IE 7]>    <html class="no-js ie7 oldie" lang="en"> <![endif]-->
<!--[if IE 8]>    <html class="no-js ie8 oldie" lang="en"> <![endif]-->
<!--[if gt IE 8]><!--> <html class="no-js" lang="en"> <!--<![endif]-->
  <head>
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge, chrome=1" />

    <title>Authentication</title>

    <meta name="viewport" content="width=device-width, initial-scale=1.0" />

    <link rel="stylesheet" href="/stylesheets/main.css" />
  </head>
  <body>
    <div class="wrapper">
      <nav>
        <a href="/posts">Posts</a>
        <% if !logged_in? %>
          <a href="/login">Log In</a>
          <a href="/users/new">Sign Up</a>
        <% else %>
          <a href="/posts/new">New Post</a>
          <form method="post" action="/logout" style="display: inline-block;">
            <input type="hidden" name="_method" value="delete" />
            <input type="submit" value="Log Out" />
          </form>
        <% end %>
      </nav>
      <%= styled_flash %>
        <%= yield %>

      <footer class="branding">
        <small>&copy; 2020 <strong>Authentication</strong></small>
      </footer>
    </div>

    <script src="http://ajax.googleapis.com/ajax/libs/jquery/1/jquery.min.js"></script>
    <!--[if lt IE 7]>
      <script src="//ajax.googleapis.com/ajax/libs/chrome-frame/1.0.2/CFInstall.min.js"></script>
      <script>window.attachEvent("onload",function(){CFInstall.check({mode:"overlay"})})</script>
    <![endif]-->
  </body>
</html>

```

Finally we add a private method to the PostsController, that will find a Post based on params[:id] and then redirect to /posts with an error message if we don't find a Post with that id

```ruby
def set_post 
  @post = Post.find_by_id(params[:id])
  if @post.nil?
    flash[:error] = "Couldn't find a Post with id: #{params[:id]}"
    redirect "/posts"
  end
end
```

To get this working, we need to call this method from the routes in our controller that need to find a Post based on an id in params:

```rb
  # GET: /posts/5 -> show
  get "/posts/:id" do
    set_post
    erb :"/posts/show.html"
  end

  # GET: /posts/5/edit -> edit
  get "/posts/:id/edit" do
    set_post
    erb :"/posts/edit.html"
  end

  # PATCH: /posts/5 -> update
  patch "/posts/:id" do
    set_post
    redirect "/posts/:id"
  end

  # DELETE: /posts/5 - destroy
  delete "/posts/:id" do
    set_post
    redirect "/posts"
  end
```

So our posts controller now looks like this:

```rb
class PostsController < ApplicationController

  # GET: /posts -> index
  get "/posts" do
    @posts = Post.all
    erb :"/posts/index.html"
  end

  # GET: /posts/new -> new
  get "/posts/new" do
    redirect "/login" if not logged_in?
    @post = Post.new
    erb :"/posts/new.html"
  end

  # POST: /posts -> create
  post "/posts" do
    redirect "/login" if not logged_in?
    @post = current_user.posts.build(title: params[:post][:title],content:params[:post][:content])
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
    erb :"/posts/edit.html"
  end

  # PATCH: /posts/5 -> update
  patch "/posts/:id" do
    set_post
    redirect "/posts/:id"
  end

  # DELETE: /posts/5 - destroy
  delete "/posts/:id" do
    set_post
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
end

```

Let's build out the update functionality:

```rb
# PATCH: /posts/5 -> update
patch "/posts/:id" do
  set_post
  
  if @post.update(title: params[:post][:title], content:params[:post][:content])
    flash[:success] = "Post successfully updated"
    redirect "/posts/#{@post.id}"
  else 
    erb :"/posts/edit.html"
  end
end
```

We also need to make sure that only users who created a post are able to update/delete it. One way we can do this without having to repeat ourselves is to add a method that accepts a post as an argument and ensures that the logged in user has permissions to interact with that post. We could call this method `authorize_post(post)`. We'll also add a method to redirect a user if they're not authorized to perform an action:

```rb
def redirect_if_not_authorized
  if !authorize_post(@post)
    flash[:error] = "You don't have permission to do that action"
    redirect "/posts"
  end
end

def authorize_post(post)
  current_user == post.author
end
```

Once we have this method, we want to call it right before we do anything that only a user who is authorized on this post should be able to do. This is what our controller should look like:

```rb
class PostsController < ApplicationController

  # GET: /posts -> index
  get "/posts" do
    @posts = Post.all
    erb :"/posts/index.html"
  end

  # GET: /posts/new -> new
  get "/posts/new" do
    redirect "/login" if not logged_in?
    @post = Post.new
    erb :"/posts/new.html"
  end

  # POST: /posts -> create
  post "/posts" do
    redirect "/login" if not logged_in?
    @post = current_user.posts.build(title: params[:post][:title], content:params[:post][:content])
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
    if @post.update(title: params[:post][:title], content:params[:post][:content])
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
    if !authorize_post(@post)
      flash[:error] = "You don't have permission to do that action"
      redirect "/posts"
    end
  end

  def authorize_post(post)
    current_user == post.author
  end

end

```

## Protecting Routes behind a login requirement

To make sure users can only access routes that are protected when they are logged in, we can add a private method in the ApplicationController class:

```rb
def redirect_if_not_logged_in
  if !logged_in?
    flash[:error] = "You must be logged in to view that page"
    redirect request.referrer || "/login"
  end
end
```

Once we have this method, we can call it in any controller action (route) where we want only logged in users to be able to visit.
Now, we've got our CRUD functionality working, we can use some conditional logic in views to only display links/buttons when appropriate.

For example, in `app/views/posts/show.html.erb`

```html
<!-- app/views/posts/show.html.erb -->
<h1><%= @post.title %></h1>
<p><%= @post.author.email %></p>
<p><%= @post.content %></p>
<% if authorize_post(@post) %>
  <div>
    <a href="/posts/<%= @post.id %>/edit"><button>Edit</button></a> 
    <form method="post" action="/posts/<%= @post.id %>" style="display: inline-block;">
      <input type="hidden" name="_method" value="delete" />
      <input type="submit" value="Delete" />
    </form>
  </div>
<% end %>
```
























Note about || and &&:

```
>> true || false
=> true
>> false || true
=> true
>> false || nil
=> nil
>> true && false
=> false
>> true && nil
=> nil
>> true && "hello"
=> "hello"
>> nil && "hello"
=> nil
```