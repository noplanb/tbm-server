FactoryGirl.define do
  factory :credential do
    sequence(:cred_type)  {|n| "cred_type_#{n}"}
    cred "cred"
  end
  

end
