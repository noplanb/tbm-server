FactoryGirl.define do
  factory :connection do
    association :creator, factory: :user
    association :target, factory: :user
    status :established
  end
end
