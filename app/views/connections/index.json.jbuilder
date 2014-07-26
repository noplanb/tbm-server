json.array!(@connections) do |connection|
  json.extract! connection, :id, :creator_id_id, :target_id, :status
  json.url connection_url(connection, format: :json)
end
