class Position < ApplicationRecord
  POSITION_TYPES = %w(army fleet).freeze

  belongs_to :area
  belongs_to :coast, optional: true
  belongs_to :user_game
  has_one :user, through: :user_game
  has_one :game, through: :user_game

  validates_inclusion_of :type, in: POSITION_TYPES
end
