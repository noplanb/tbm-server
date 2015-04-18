module TwimlHelpers

  def twiml_says_error?(twiml)
    twiml.match(/error/)
  end

  def twiml_says_verification_code?(twiml)
    twiml_contains_verification_code_n_times?(twiml,3)
  end

  def twiml_contains_verification_code_n_times?(twiml, n)
    total_digits = twiml.scan(/ \d/).size
    total_digits == n * Settings.verification_code_length
  end

end