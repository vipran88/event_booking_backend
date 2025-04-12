FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { 'password123' }
    
    trait :event_organizer do
      role { 'event_organizer' }
      
      after(:create) do |user|
        create(:event_organizer, user: user)
      end
    end
    
    trait :customer do
      role { 'customer' }
      
      after(:create) do |user|
        create(:customer, user: user)
      end
    end
  end
end
