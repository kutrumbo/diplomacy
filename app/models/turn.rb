class Turn < ApplicationRecord
  TURN_TYPES = %w(spring spring_retreat fall fall_retreat build).freeze

  belongs_to :game

  validates_inclusion_of :type, in: TURN_TYPES
end
