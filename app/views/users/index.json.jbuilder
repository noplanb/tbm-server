json.array!(@users) do |user|
  json.extract! user, :id, :first_name, :last_name, :mobile_number, :device_platform, :auth, :mkey, :status
  json.url user_url(user, format: :json)
end
