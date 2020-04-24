class Area < ApplicationRecord
  AREA_TYPES = %w(land sea coast).freeze

  has_many :neighbors
  has_many :coasts

  validates_inclusion_of :type, in: AREA_TYPES
end
