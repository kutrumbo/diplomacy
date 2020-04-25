FactoryBot.define do
  factory :game do
    name { Faker::App.name }

    trait :started do
      after :build do |game|
        UserGame::POWER_TYPES.map do |power|
          game.user_games << create(:user_game, power: power, game: game)
        end
        create(:turn, :first, game: game)
      end
    end
  end
end
