class User < ApplicationRecord
  has_many :games, through: :user_games
  has_many :orders
  has_many :positions
end
