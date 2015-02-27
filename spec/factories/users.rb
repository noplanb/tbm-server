FactoryGirl.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    mobile_number { Faker::PhoneNumber.cell_phone }

    factory :unknown_user do
      first_name nil
      last_name nil
    end
  end
end
