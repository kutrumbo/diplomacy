class UserGame < ApplicationRecord
  POWER_TYPES = %w(austria england france germany italy russia turkey).freeze
  STATES = %w(pending confirmed)

  belongs_to :game
  belongs_to :user
  has_many :positions, dependent: :destroy
  has_many :orders, dependent: :destroy

  validates_inclusion_of :power, in: POWER_TYPES
  validates_inclusion_of :state, in: STATES
  validates :power, uniqueness: { scope: :game, message: 'Cannot repeat power within game' }

  after_save :process_turn

  def pending?
    self.state == 'pending'
  end

  private

  def process_turn
    TurnService.process_turn(self.game.current_turn)
  end
end
