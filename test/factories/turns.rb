FactoryBot.define do
  factory :turn do
    type { Turn::TURN_TYPES.sample }
    number { Faker::Number.within(range: 1..35) }
    game

    trait :first do
      number { 1 }
      type { Turn::TURN_TYPES.first }
    end
  end
end
