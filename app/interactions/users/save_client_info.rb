class Users::SaveClientInfo < ActiveInteraction::Base
  ALLOWED_PLATFORMS = %w(ios android)

  object :user
  string :device_platform
  string :device_info, default: nil
  string :app_version

  validates :device_platform, inclusion: { in: ALLOWED_PLATFORMS,
                                           message: '%{value} is not allowed' }

  def execute
    update_attributes if update_required?
  end

  private

  def update_required?
    %i(device_platform device_info app_version).any? do |attr|
      user.send(attr).to_s != send(attr).to_s
    end
  end

  def update_attributes
    new_attrs = { device_platform: device_platform, app_version: app_version }
    new_attrs.merge(device_info: device_info) if device_info
    user.update_attributes(new_attrs)
  end
end
