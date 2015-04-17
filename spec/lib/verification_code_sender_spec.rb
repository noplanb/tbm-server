require 'rails_helper'

RSpec.describe VerificationCodeSender do
  MESSAGE_PREFIX = "#{Settings.app_name} access code:"
  let(:mobile_number) { Figaro.env.twilio_to_number }
  let(:user) { build(:user, mobile_number: mobile_number) }
  let(:instance) { described_class.new(user) }

  describe '#from' do
    subject { instance.from }
    it { is_expected.to eq(Figaro.env.twilio_from_number) }
  end

  describe '#to' do
    subject { instance.to }
    it { is_expected.to eq(mobile_number) }
  end

  describe '#message' do
    let(:user) { build(:user) }
    it "starts with '#{MESSAGE_PREFIX}'" do
      expect(instance.message.match /^#{MESSAGE_PREFIX}/)
    end

    it "ends with access code" do
      code = instance.message.match(/\d+$/).to_s
      expect(code.length).to eq Settings.verification_code_length
    end
  end

  describe '#send_verification_sms' do
    subject { instance.send_verification_sms }

    context 'on success' do
      it do
        VCR.use_cassette('twilio_success_response', erb: {
                           twilio_ssid: Figaro.env.twilio_ssid,
                           twilio_token: Figaro.env.twilio_token,
                           from: Figaro.env.twilio_from_number,
                           to: mobile_number }) do
          is_expected.to eq(:ok)
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
          is_expected.to eq(:invalid_mobile_number)
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
          is_expected.to eq(:other)
        end
      end
    end
  end
end
