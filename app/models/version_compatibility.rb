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
            presence: true, numericality: { only_integer: true }

  validates :ios_optional_upgrade_version_threshold,
            :android_optional_upgrade_version_threshold,
            numericality: { only_integer: true, allow_nil: true }

  after_initialize :set_defaults

  def compatibility(device_platform, version)
    return :unsupported if device_platform.blank? || !SUPPORTED_DEVICE_PLATFORMS.include?(device_platform.to_sym)
    fail ArgumentError, 'version must be an integer' unless version.to_s.match(/^\d+$/)

    version = version.to_i
    mandatory_threshold = cred["#{device_platform}_mandatory_upgrade_version_threshold"].to_i
    optional_threshold = cred["#{device_platform}_optional_upgrade_version_threshold"].to_i

    if version < mandatory_threshold
      :update_required
    elsif optional_threshold && version >= mandatory_threshold && version < optional_threshold
      :update_optional
    else
      :current
    end
  end

  def update_credentials(credentials)
    super HashWithIndifferentAccess[credentials.map { |k, v| [k, v.to_i] }]
  end

  private

  def set_defaults
    if ios_mandatory_upgrade_version_threshold.blank?
      self.ios_mandatory_upgrade_version_threshold = IOS_MANDATORY_DEFAULT_THRESHOLD
    end
    if android_mandatory_upgrade_version_threshold.blank?
      self.android_mandatory_upgrade_version_threshold = ANDROID_MANDATORY_DEFAULT_THRESHOLD
    end
  end
end
