class User < ActiveRecord::Base
  include EnumHandler
  
  define_enum :device_platform, [:ios,:android], :primary => true
  
  def name
    [first_name,last_name].join(" ")
  end
  
end
