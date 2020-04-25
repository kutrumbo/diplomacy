class Turn < ApplicationRecord
  TURN_TYPES = %w(spring spring_retreat fall fall_retreat build).freeze
  self.inheritance_column = :_type_disabled # disable single-table inheritance

  belongs_to :game

  validates_inclusion_of :type, in: TURN_TYPES

  def year
    1901 + (number / 5)
  end
end
