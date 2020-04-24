class Coast < ApplicationRecord
  DIRECTION_TYPES = %w(north east south).freeze

  belongs_to :area
  has_many :neighbors

  validates_inclusion_of :direction, in: DIRECTION_TYPES
end
