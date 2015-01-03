json.array!(@s3_infos) do |s3_info|
  json.extract! s3_info, :id, :region, :bucket, :access_key, :secret_key
  json.url s3_info_url(s3_info, format: :json)
end
