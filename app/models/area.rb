class Area < ApplicationRecord
  AREA_TYPES = %w(land sea).freeze
  self.inheritance_column = :_type_disabled # disable single-table inheritance

  has_many :borders
  has_many :neighboring_areas, through: :borders, source: :neighbor, source_type: 'Area'
  has_many :neighboring_coasts, through: :borders, source: :neighbor, source_type: 'Coast'
  has_many :coasts

  validates_inclusion_of :type, in: AREA_TYPES
  validates_inclusion_of :power, in: UserGame::POWER_TYPES, allow_nil: true

  def has_coasts?
    self.coasts.present?
  end

  def coastal?
    self.neighboring_areas.where(type: 'sea').any?
  end
end
