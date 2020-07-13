class Position < ApplicationRecord
  POSITION_TYPES = %w(army fleet).freeze
  self.inheritance_column = :_type_disabled # disable single-table inheritance

  belongs_to :area
  belongs_to :coast, optional: true
  belongs_to :user_game
  belongs_to :turn
  has_one :user, through: :user_game
  has_one :game, through: :user_game
  has_one :order
  has_many :neighboring_areas, through: :area
  has_many :neighboring_coasts, through: :area

  validates_inclusion_of :type, in: POSITION_TYPES, allow_nil: true
  validates_inclusion_of :power, in: UserGame::POWER_TYPES, allow_nil: true

  scope :with_unit, -> { where.not(type: nil) }
  scope :with_army, -> { where(type: 'army') }
  scope :with_fleet, -> { where(type: 'fleet') }
  scope :no_unit, -> { where(type: nil) }
  scope :supply_center, -> { joins(:area).where(areas: { supply_center: true }) }
  scope :occupied, -> { where.not(power: nil) }
  scope :retreating, -> { where(dislodged: true) }
  scope :turn, -> (turn) { where(turn: turn) }
  scope :includes_areas, -> { includes(area: [:neighboring_areas, :neighboring_coasts]) }
  scope :power, -> (power) { where(power: power) }
  scope :not_power, -> (power) { where.not(power: power).or(Position.where(power: nil)) }
  scope :occupied_by, -> (user_game) { where(user_game: user_game) }
  scope :not_occupied_by, -> (user_game) { where.not(user_game: user_game) }

  def army?
    self.type == 'army'
  end

  def fleet?
    self.type == 'fleet'
  end

  def coast?
    self.coast.present?
  end
end
