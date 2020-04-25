FactoryBot.define do
  factory :coast do
    area
    direction { Coast::DIRECTION_TYPES.sample }
  end
end
