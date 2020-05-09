class Resolution < ApplicationRecord
  STATUS_TYPES = %w(resolved dislodged cancelled invalid bounced broken cut failed).freeze

  belongs_to :order

  validates_inclusion_of :status, in: STATUS_TYPES
end
