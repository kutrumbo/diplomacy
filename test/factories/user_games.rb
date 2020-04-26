FactoryBot.define do
  factory :user_game do
    power { UserGame::POWER_TYPES.sample }
    state { 'pending' }
    game
    user
  end
end
