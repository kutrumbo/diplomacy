FactoryBot.define do
  factory :user_game do
    power { UserGame::POWER_TYPES.sample }
    game
    user
  end
end
