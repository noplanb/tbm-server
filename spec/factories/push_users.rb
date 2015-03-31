FactoryGirl.define do
  factory :push_user do
    mkey { Faker::Lorem.characters(20) }
    push_token { Faker::Lorem.characters(20) }
    device_platform { [:ios, :android].sample }
    device_build :dev
  end
end
