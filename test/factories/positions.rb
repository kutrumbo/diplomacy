FactoryBot.define do
  factory :position do
    type { Position::POSITION_TYPES.sample }
    power { nil }
    dislodged { false }
    area
    turn
    user_game
  end
end
