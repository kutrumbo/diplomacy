FactoryBot.define do
  factory :order do
    type { 'hold' }
    user_game
    turn
    position
  end
end
