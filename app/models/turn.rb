class Turn < ApplicationRecord
  TURN_TYPES = %w(spring spring_retreat fall fall_retreat winter).freeze
  self.inheritance_column = :_type_disabled # disable single-table inheritance

  belongs_to :game
  has_many :orders, dependent: :destroy
  has_many :positions, dependent: :destroy
  has_many :user_games, through: :game

  validates_inclusion_of :type, in: TURN_TYPES

  def year
    1901 + (number / 5)
  end

  def attack?
    ['spring', 'fall'].include?(self.type)
  end

  def retreat?
    ['spring_retreat', 'fall_retreat'].include?(self.type)
  end

  def build?
    self.type == 'winter'
  end

  def previous_turn
    self.game.turns.find_by(number: self.number - 1)
  end
end
