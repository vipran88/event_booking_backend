FactoryBot.define do
  factory :ticket do
    ticket_type { ['VIP', 'Regular', 'Early Bird'].sample }
    price { Faker::Number.decimal(l_digits: 2, r_digits: 2) }
    quantity_available { Faker::Number.between(from: 10, to: 100) }
    association :event
  end
end
