class Game < ApplicationRecord
  has_many :turns, dependent: :destroy
  has_many :user_games, dependent: :destroy
  has_many :users, through: :user_games
end
