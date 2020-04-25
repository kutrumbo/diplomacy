class Coast < ApplicationRecord
  DIRECTION_TYPES = %w(north east south).freeze

  belongs_to :area

  validates_inclusion_of :direction, in: DIRECTION_TYPES
end
