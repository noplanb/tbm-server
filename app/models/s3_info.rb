class S3Info < ActiveRecord::Base
  
  def only_app_attributes
    attributes.symbolize_keys.slice(:region, :bucket, :access_key, :secret_key)
  end
end
