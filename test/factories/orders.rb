FactoryBot.define do
  factory :order do
    type { 'hold' }
    confirmed { false }
    user_game
    turn
    position
  end
end
