FactoryBot.define do
  factory :user do
    name { Faker::Name.first_name }
    email { Faker::Internet.email }
    password { Faker::Alphanumeric.alphanumeric(number: 16) }
  end
end
