FactoryGirl.define do
  factory :message do
    message_id { (Time.now.to_f + 1000).to_i.to_s }
    message_type 'video'
  end
end
