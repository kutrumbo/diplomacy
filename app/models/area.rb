class Area < ApplicationRecord
  AREA_TYPES = %w(land sea).freeze
  self.inheritance_column = :_type_disabled # disable single-table inheritance

  has_many :neighbors
  has_many :coasts

  validates_inclusion_of :type, in: AREA_TYPES
  validates_inclusion_of :power, in: UserGame::POWER_TYPES, allow_nil: true
end
