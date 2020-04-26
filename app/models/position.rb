class Position < ApplicationRecord
  POSITION_TYPES = %w(army fleet).freeze
  self.inheritance_column = :_type_disabled # disable single-table inheritance

  belongs_to :area
  belongs_to :coast, optional: true
  belongs_to :user_game
  has_one :user, through: :user_game
  has_one :game, through: :user_game
  has_many :neighboring_areas, through: :area

  validates_inclusion_of :type, in: POSITION_TYPES, allow_nil: true

  scope :with_unit, -> { where.not(type: nil) }
  # TODO add logic to make sure not retreating
  scope :owns_supply_center, -> { joins(:area).where(areas: { supply_center: true }) }

  def army?
    self.type == 'army'
  end

  def fleet?
    self.type == 'fleet'
  end

  def retreat?
    # TODO
    false
  end
end
