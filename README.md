# Authentication in Sinatra

In order to implement Authentication in Sinatra, we're going to need to address the following tasks:
1. Enable the rack session cookie middleware. 
2. Generate a session secret so that our cookies are securely encrypted. 
3. Create a `User` model that stores an email/username and encrypted password
4. implement the `has_secure_password` macro in the `User` model to enable storing an encrypted version of the password and authenticating against that.
5. Build forms for sign up and log in and links to the routes that render them
6. Build out controllers that handle rendering forms and responding to their submission
7. Use the methods from `has_secure_password` to create user accounts and authenticate them later, storing the user's ID in session cookies using the `session` hash in our controllers.

## Dependencies (Gems/packages)
- (✔) 'activerecord'
- (✔) 'bcrypt'
- (✔) 'dotenv'
- (✔) 'session_secret_generator'
## Configuration (environment variables/other stuff in config folder)
- (✔) enable sessions in the controller
- (✔) set session secret in controller to `ENV['SESSION_SECRET']`
- (✔) create `SESSION_SECRET` in a file called `.env` 
- (✔) load the varibles in the `.env` file using `Dotenv.load` in `config/environment`. 
- (✔) to test this is working, open `bundle exec tux` and type in `ENV['SESSION_SECRET']` You should see the value inside of the `.env` file. 
- eventually we'll have to load our 2 controllers within the `config.ru` file as well
- (✔) we'll need to add the `method_override` so that we're able to send a delete request for `/logout`
## Database
- (✔) Users table with a column `password_digest` and some other column to find a user by (email or username)
## Models
- (✔) User model that inherits from `ActiveRecord::Base` and invokes the `has_secure_password` macro.
## Controllers
- `SessionsController` for logging in and out
- (✔) `UsersController` for creating new accounts
## Routes
- `get '/login'` for rendering the log in form
- `post '/login'` for handling the log in form submission
- `delete '/logout` for handling a logout button click.
- (✔) `get '/users/new'` for rendering the registration form
- (✔) `post '/users` for handling the registration form submission.
## Views
- (✔) view with registration form for creating a new account
- view with login form for logging into an existing account
- navigation links in `layout.erb` for authenication (conditional logic for displaying a logout button)


# How to Follow along

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