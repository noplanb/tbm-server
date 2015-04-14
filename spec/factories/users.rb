FactoryGirl.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    mobile_number { Faker::PhoneNumber.cell_phone }

    factory :unknown_user do
      first_name nil
      last_name nil
    end

    factory :ios_user do
      device_platform :ios
    end

    factory :android_user do
      device_platform :android
    end
  end
end
