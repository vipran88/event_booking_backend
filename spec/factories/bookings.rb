FactoryBot.define do
  factory :booking do
    quantity { Faker::Number.between(from: 1, to: 5) }
    total_price { nil } # Will be calculated in the model
    association :customer
    association :ticket
  end
end
