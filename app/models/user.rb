class User < ActiveRecord::Base
  has_secure_password
  validates :email, presence: true, uniqueness: true
  has_many :posts, foreign_key: "author_id"
end