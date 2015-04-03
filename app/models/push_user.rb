class PushUser < ActiveRecord::Base
  include EnumHandler

  define_enum :device_platform, [:ios, :android], primary: true
  define_enum :device_build, [:dev, :prod]

  def self.create_or_update(params)
    params = params.slice(:mkey, :push_token, :device_platform, :device_build)
    push_user = PushUser.find_by_mkey(params[:mkey])
    if push_user
      push_user.update_attributes(params)
    else
      PushUser.create(params)
    end
  end

  def send_notification(options = {})
    GenericPushNotification.send_notification(options.reverse_merge(
                                                platform: device_platform,
                                                build: device_build,
                                                token: push_token,
                                                content_available: true))
  end
end
