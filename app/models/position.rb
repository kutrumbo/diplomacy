class Position < ApplicationRecord
  POSITION_TYPES = %w(army fleet).freeze
  self.inheritance_column = :_type_disabled # disable single-table inheritance

  belongs_to :area
  belongs_to :coast, optional: true
  belongs_to :user_game
  has_one :user, through: :user_game
  has_one :game, through: :user_game

  validates_inclusion_of :type, in: POSITION_TYPES, allow_nil: true

  def fleet?
    self.type == 'fleet'
  end
end
