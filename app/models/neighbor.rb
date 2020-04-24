class Neighbor < ApplicationRecord
  belongs_to :area
  belongs_to :neighbor, polymorphic: true
end
