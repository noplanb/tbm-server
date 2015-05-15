class VersionCompatibility < Credential
  include SpecificCredential

  SUPPORTED_DEVICE_PLATFORMS = %i(ios android)
  IOS_MANDATORY_DEFAULT_THRESHOLD = 22
  ANDROID_MANDATORY_DEFAULT_THRESHOLD = 42

  define_attributes :ios_mandatory_upgrade_version_threshold,
                    :ios_optional_upgrade_version_threshold,
                    :android_mandatory_upgrade_version_threshold,
                    :android_optional_upgrade_version_threshold

  validates :ios_mandatory_upgrade_version_threshold,
            :android_mandatory_upgrade_version_threshold,
            presence: true

  def compatibility(device_platform, version)
    return :unsupported unless SUPPORTED_DEVICE_PLATFORMS.include?(device_platform.to_sym)
    mandatory_threshold = cred["#{device_platform}_mandatory_upgrade_version_threshold"] ||
                          self.class.const_get("#{device_platform.upcase}_MANDATORY_DEFAULT_THRESHOLD")
    optional_threshold = cred["#{device_platform}_optional_upgrade_version_threshold"]

    if version < mandatory_threshold
      :update_required
    elsif optional_threshold && version >= mandatory_threshold && version < optional_threshold
      :update_optional
    else
      :current
    end
  end
end
