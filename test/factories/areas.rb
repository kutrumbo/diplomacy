FactoryBot.define do
  factory :area do
    name { Faker::Address.country }
    type { Area::AREA_TYPES.sample }
    supply_center { [true, false].sample }
    power { [*UserGame::POWER_TYPES, nil].sample }
    unit { [*Position::POSITION_TYPES, nil].sample }
  end
end
