FactoryGirl.define do
  factory :kvstore do
    key1 'smRug5xj8J469qX5XvGk-IUed5vP9n4qzW6jY8wSu-d8b49aa0143e0cc66ee154fab6538083-VideoIdKVKey'
    key2 { (Time.now.to_f + 1000).to_i.to_s }
    value { { video_id: key2 }.to_json }
  end
end
