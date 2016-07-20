class Users::SaveDeviceInfo < ActiveInteraction::Base
  ALLOWED_PLATFORMS = %w(ios android)

  object :user
  string :platform
  string :version

  validates :platform, inclusion: { in: ALLOWED_PLATFORMS,
                                    message: '%{value} is not allowed' }

  def execute
    update_attributes if update_required?
  end

  private

  def update_required?
    user.device_platform.to_s != platform || user.app_version != version
  end

  def update_attributes
    user.update_attributes(device_platform: platform, app_version: version)
  end
end
