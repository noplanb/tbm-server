require 'rails_helper'

RSpec.describe SmsManager, type: :model do
  let(:mobile_number) { Figaro.env.twilio_to_number }
  let(:user) { build(:user, mobile_number: mobile_number) }
  let(:instance) { described_class.new }

  describe '#from' do
    subject { instance.from }
    it { is_expected.to eq(Figaro.env.twilio_from_number) }
  end

  describe '#to' do
    subject { instance.to(user) }
    it { is_expected.to eq(mobile_number) }
  end

  describe '#message' do
    subject { instance.message(user) }
    let(:user) { build(:user, verification_code: 123456) }
    it { is_expected.to eq("#{APP_CONFIG[:app_name]} access code: 123456") }
  end

  describe '#send_verification_sms' do
    subject { instance.send_verification_sms(user) }

    context 'on success' do
      it do
        VCR.use_cassette('twilio_success_response', erb: {
                           twilio_ssid: Figaro.env.twilio_ssid,
                           twilio_token: Figaro.env.twilio_token,
                           from: Figaro.env.twilio_from_number,
                           to: mobile_number }) do
          is_expected.to eq(0)
        end
      end
    end

    context 'on invalid number' do
      let(:mobile_number) { '+20227368296' }
      let(:error) { { code: 21_614, message: "'To' number is not a valid mobile number" } }
      it do
        VCR.use_cassette('twilio_error_response', erb: {
          twilio_ssid: Figaro.env.twilio_ssid,
          twilio_token: Figaro.env.twilio_token,
          from: Figaro.env.twilio_from_number,
          to: mobile_number }.merge(error)) do
          is_expected.to eq(1)
        end
      end
    end

    context 'other error' do
      let(:mobile_number) { '+20227368296' }
      let(:error) { { code: 14_101, message: "'To' Attribute is Invalid" } }
      it do
        VCR.use_cassette('twilio_error_response', erb: {
          twilio_ssid: Figaro.env.twilio_ssid,
          twilio_token: Figaro.env.twilio_token,
          from: Figaro.env.twilio_from_number,
          to: mobile_number }.merge(error)) do
          is_expected.to eq(2)
        end
      end
    end
  end
end
