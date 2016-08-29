module User::VerificationMethods
  def reset_verification_code
    set_verification_code if verification_code.blank? || verification_code_will_expire_in?(2)
  end

  def get_verification_code
    reset_verification_code
    verification_code
  end

  def passes_verification(code)
    code = code.gsub(/\s/, '')
    backdoor = ENV['verification_code_backdoor']
    !Rails.env.production? && backdoor && backdoor == code ||
      !verification_code_expired? && verification_code == code
  end

  def set_verification_code
    update_attributes(verification_code: random_number(Settings.verification_code_length),
                      verification_date_time: (Settings.verification_code_lifetime_minutes.minutes.from_now))
  end

  def random_number(n)
    rand.to_s[2..n + 1]
  end

  def verification_code_expired?
    verification_code_will_expire_in?(0)
  end

  def verification_code_will_expire_in?(n)
    return true if verification_code.blank? || verification_date_time.blank?
    return true if verification_date_time < n.minutes.from_now
    false
  end
end
