class Game < ApplicationRecord
  has_many :turns, dependent: :destroy
  has_many :user_games, dependent: :destroy
  has_many :positions, through: :user_games
  has_many :users, through: :user_games

  def current_turn
    self.turns.order(:number).last
  end
end
