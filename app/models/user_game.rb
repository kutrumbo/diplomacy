class UserGame < ApplicationRecord
  POWER_TYPES = %w(austria england france germany italy russia turkey).freeze

  belongs_to :game
  belongs_to :user

  validates_inclusion_of :power, in: POWER_TYPES
end
