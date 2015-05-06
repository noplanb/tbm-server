FactoryGirl.define do
  factory :connection do
    association :creator, factory: :user
    association :target, factory: :user

    trait :established do
      status :established
    end

    factory :established_connection, traits: [:established]
  end
end
