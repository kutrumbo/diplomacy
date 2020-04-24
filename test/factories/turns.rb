FactoryBot.define do
  factory :turn do
    type { 'spring' }
    number { 1 }
    game
  end
end
