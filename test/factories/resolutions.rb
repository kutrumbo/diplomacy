FactoryBot.define do
  factory :resolution do
    status { Resolution::STATUS_TYPES.sample }
    order
  end
end
