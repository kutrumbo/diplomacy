class Turn < ApplicationRecord
  TURN_TYPES = %w(spring spring_retreat fall fall_retreat winter).freeze
  self.inheritance_column = :_type_disabled # disable single-table inheritance

  belongs_to :game
  has_many :orders
  has_many :positions, through: :game
  has_many :user_games, through: :game

  validates_inclusion_of :type, in: TURN_TYPES

  after_create :prepare_orders

  def year
    1901 + (number / 5)
  end

  def attack?
    ['spring', 'fall'].include?(self.type)
  end

  def retreat?
    ['spring_retreat', 'fall_retreat'].include?(self.type)
  end

  def build?
    self.type == 'winter'
  end

  private

  def prepare_orders
    self.game.positions.with_unit.each do |position|
      self.orders.create!(
        type: 'hold',
        user_game: position.user_game,
        position: position,
        from_id: position.area_id,
        to_id: position.area_id,
      )
    end
  end
end
