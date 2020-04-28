class Position < ApplicationRecord
  POSITION_TYPES = %w(army fleet).freeze
  self.inheritance_column = :_type_disabled # disable single-table inheritance

  belongs_to :area
  belongs_to :coast, optional: true
  belongs_to :user_game
  belongs_to :turn
  has_one :user, through: :user_game
  has_one :game, through: :user_game
  has_many :neighboring_areas, through: :area

  validates_inclusion_of :type, in: POSITION_TYPES, allow_nil: true
  validates_inclusion_of :power, in: UserGame::POWER_TYPES, allow_nil: true

  scope :with_unit, -> { where.not(type: nil) }
  scope :unoccupied, -> { where(type: nil) }
  scope :supply_center, -> { joins(:area).where(areas: { supply_center: true }) }

  after_create :prepare_order

  def army?
    self.type == 'army'
  end

  def fleet?
    self.type == 'fleet'
  end

  private

  def prepare_order
    if self.type.present?
      self.turn.orders.create!(
        type: 'hold',
        user_game: self.user_game,
        from_id: self.area_id,
        to_id: self.area_id,
        confirmed: false,
        position: self,
      )
    end
  end
end
