class UserGame < ApplicationRecord
  POWER_TYPES = %w(austria england france germany italy russia turkey).freeze

  belongs_to :game
  belongs_to :user
  has_many :positions, dependent: :destroy
  has_many :orders, dependent: :destroy

  validates_inclusion_of :power, in: POWER_TYPES
  validates :power, uniqueness: { scope: :game, message: 'Cannot repeat power within game' }

  scope :winner, -> { where(winner: true) }
  scope :draw, -> { where(draw: true) }
end
