require 'rspec/expectations'

RSpec::Matchers.define :say_twiml_error do |expected|
  match do |actual|
    actual.match(/error/).present?
  end
end

RSpec::Matchers.define :say_twiml_verification_code do |expected|
  match do |actual|
    total_digits = actual.scan(/ \d/).size
    total_digits == 3 * Settings.verification_code_length
  end
end
