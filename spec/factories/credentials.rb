FactoryGirl.define do
  factory :credential do
    sequence(:cred_type)  { |n| "cred_type_#{n}" }
    cred 'cred'
  end

  factory :s3_credential, class: S3Credential do
    region 'us-west-1'
    bucket 'bucket'
    access_key 'access_key'
    secret_key 'secret_key'
  end
end
