class Resolution < ApplicationRecord
  STATUS_TYPES = %w(resolved dislodged cancelled invalid bounced broken cut failed).freeze

  belongs_to :order

  validates_inclusion_of :status, in: STATUS_TYPES

  STATUS_TYPES.each do |resolution_status|
    define_method("#{resolution_status}?") do
      self.status == resolution_status
    end
  end
end
