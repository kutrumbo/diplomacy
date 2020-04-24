class Neighbor < ApplicationRecord
  belongs_to :area
  has_one :neighbor, polymorphic: true
end
