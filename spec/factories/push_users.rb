FactoryGirl.define do
  factory :push_user do
    mkey { Faker::Lorem.characters(20) }
    push_token { Faker::Lorem.characters(20) }
    device_platform { [:ios, :android].sample }
    device_build :dev

    trait :android do
      device_platform :android
    end

    trait :ios do
      device_platform :ios
    end

    trait :dev_build do
      device_build :dev
    end

    trait :prod_build do
      device_build :prod
    end

    factory :android_push_user, traits: [:android]
    factory :ios_push_user, traits: [:ios]
  end
end
