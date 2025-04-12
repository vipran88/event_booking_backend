FactoryBot.define do
  factory :event do
    title { Faker::Conference.name }
    description { Faker::Lorem.paragraph }
    venue { Faker::Address.full_address }
    event_date { Faker::Time.forward(days: 30) }
    capacity { Faker::Number.between(from: 50, to: 500) }
    association :event_organizer
  end
end
