class Area < ApplicationRecord
  AREA_TYPES = %w(land sea).freeze
  self.inheritance_column = :_type_disabled # disable single-table inheritance

  has_many :borders
  has_many :neighboring_areas, through: :borders, source: :neighbor, source_type: 'Area'
  has_many :neighboring_coasts, through: :borders, source: :neighbor, source_type: 'Coast'
  has_many :coasts

  validates_inclusion_of :type, in: AREA_TYPES
  validates_inclusion_of :power, in: UserGame::POWER_TYPES, allow_nil: true
  validates_inclusion_of :unit, in: Position::POSITION_TYPES, allow_nil: true
  validates_inclusion_of :coast, in: Coast::DIRECTION_TYPES, allow_nil: true

  scope :land, -> { where(type: 'land') }
  scope :sea, -> { where(type: 'sea') }
  scope :coastal, -> { land.includes(:neighboring_areas).where(borders: { coastal: true }, neighboring_areas_areas: { type: 'sea' }) }
  scope :army_accessible, -> { land }
  scope :fleet_accessible, -> { includes(:neighboring_areas).sea.or(coastal).distinct }
  scope :has_coasts, -> { joins(:coasts).distinct }
  scope :supply_center, -> { where(supply_center: true) }
  scope :starting_army, -> { where(unit: 'army') }
  scope :starting_fleet, -> { where(unit: 'fleet') }
  scope :starting_power, -> (power) { where(power: power) }

  def has_coasts?
    self.coasts.present?
  end

  def coastal?
    self.land? && self.neighboring_areas.where(type: 'sea').any?
  end

  def sea?
    self.type == 'sea'
  end

  def land?
    self.type == 'land'
  end
end
