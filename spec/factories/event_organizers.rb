FactoryBot.define do
  factory :event_organizer do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    association :user
  end
end
