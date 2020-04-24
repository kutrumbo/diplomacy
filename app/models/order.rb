class Order < ApplicationRecord
  ORDER_TYPES = %w(hold move support convoy build retreat).freeze
  self.inheritance_column = :_type_disabled # disable single-table inheritance

  belongs_to :user_game
  has_one :game, through: :user_game
  has_one :user, through: :user_game
  belongs_to :turn
  belongs_to :position
  belongs_to :from, class_name: :area, optional: true
  belongs_to :to, class_name: :area, optional: true

  validates_inclusion_of :type, in: ORDER_TYPES
end
