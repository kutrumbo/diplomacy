FactoryBot.define do
  factory :position do
    type { Position::POSITION_TYPES.sample }
    area
    user_game
  end
end
