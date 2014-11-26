class PushUser < ActiveRecord::Base
  include EnumHandler
  
  define_enum :device_platform, [:ios,:android], :primary => true
  define_enum :device_build, [:dev,:prod]
  
  def self.create_or_update(params)
    params = params.slice(:mkey, :push_token, :device_platform, :device_build)
    if push_user = PushUser.find_by_mkey(params[:mkey])
      push_user.update_attributes(params)
    else
      PushUser.create(params)
    end
  end
  
end
