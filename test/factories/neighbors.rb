FactoryBot.define do
  factory :neighbor do
    area
    association :neighbor, factory: :area
  end
end
