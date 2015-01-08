class S3Info < ActiveRecord::Base
  
  
  validates :region, inclusion: { in: region_list=%w(us_east_1 us_west_1 us_west_2 ap_southeast_1 ap_southeast_2 ap_northeast_1 sa_east_1), message: "bust either: #{region_list.join(', ')}" }
  
  def only_app_attributes
    r = attributes.symbolize_keys.slice(:bucket, :access_key, :secret_key)
    r[:region] = region.to_s
    r
  end
  
  def region_str
    region.to_s
  end
  
end
