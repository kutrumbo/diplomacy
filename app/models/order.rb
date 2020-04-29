class Order < ApplicationRecord
  ORDER_TYPES = %w(hold move support convoy build_fleet build_army no_build retreat disband keep).freeze
  self.inheritance_column = :_type_disabled # disable single-table inheritance

  belongs_to :user_game
  has_one :game, through: :user_game
  has_one :user, through: :user_game
  belongs_to :turn
  belongs_to :position
  belongs_to :from, class_name: 'Area', optional: true
  belongs_to :to, class_name: 'Area', optional: true

  delegate :power, to: :user_game

  validates_inclusion_of :type, in: ORDER_TYPES

  scope :convoy, -> { where(type: 'convoy') }
  scope :move, -> { where(type: 'move') }
  scope :support, -> { where(type: 'support') }
  scope :from_area, -> (from) { where(from: from) }
  scope :to_area, -> (to) { where(to: to) }

  after_update { |order| TurnService.process_turn(order.turn) }

  ORDER_TYPES.each do |order_type|
    define_method("#{order_type}?") do
      self.type == order_type
    end
  end
end
