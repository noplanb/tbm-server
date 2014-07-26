class PushUser < ActiveRecord::Base
  
  def self.create_or_update(params)
    if push_user = PushUser.find_by_mkey(params[:mkey])
      push_user.update_attribute(:push_token, params[:push_token])
      push_user.update_attribute(:device_platform, params[:device_platform])
    else
      PushUser.create(params)
    end
  end
  
end
