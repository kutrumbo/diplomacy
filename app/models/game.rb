class Game < ApplicationRecord
  has_many :turns, dependent: :destroy
  has_many :user_games, dependent: :destroy
  has_many :positions, through: :user_games
  has_many :users, through: :user_games

  scope :active, -> { where(finished: false) }

  def current_turn
    self.turns.order(:number).last
  end

  def result
    if self.user_games.winner.any?
      "Winner: #{self.user_games.winner.map(&:user).map(&:name).join(', ')}"
    elsif self.user_games.draw.any?
      "Draw: #{self.user_games.draw.map(&:user).map(&:name).join(', ')}"
    else
      'Active'
    end
  end
end
