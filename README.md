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
'activerecord'
'bcrypt'
'dotenv'
'session_secret_generator'
## Configuration (environment variables/other stuff in config folder)
- enable sessions in the controller
- set session secret in controller to `ENV['SESSION_SECRET']`
- create `SESSION_SECRET` in a file called .env
- load the varibles in the `.env` file using `Dotenv.load` in `config/environment`.
- to test this is working, open `bundle exec tux` and type in `ENV['SESSION_SECRET']` You should see the value inside of the `.env` file.
- eventually we'll have to load our 2 controllers within the `config.ru` file as well
## Database
Users table with a column `password_digest` and some other column to find a user by (email or username)
## Models
User model that inherits from `ActiveRecord::Base` and invokes the `has_secure_password` macro.
## Views
- view with registration form for creating a new account
- view with login form for logging into an existing account
- navigation links in layout.erb for authenication (conditional logic for displaying a logout button)
## Controllers
- `SessionsController` for logging in and out
- `UsersController` for creating new accounts
## Routes
- `get '/login'` for rendering the log in form
- `post '/login'` for handling the log in form submission
- `delete '/logout` for handling a logout button click.
- `get '/users/new'` for rendering the registration form
- `post '/users/` for handling the registration form submission.
