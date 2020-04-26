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

  private

  def prepare_orders
    self.game.positions.with_unit.each do |position|
      self.orders.create!(
        type: 'hold',
        user_game: position.user_game,
        position: position,
      )
    end
  end
end
