class User < ApplicationRecord
  has_secure_password

  has_many :user_games
  has_many :games, through: :user_games
  has_many :orders
  has_many :positions

  validates :email, presence: true, uniqueness: true

  before_create { |user| user.email = user.email.downcase }
end
