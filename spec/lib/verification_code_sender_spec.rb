require 'rails_helper'
RSpec.configure { |c| c.include PhoneNumberHelpers }

RSpec.describe VerificationCodeSender do
  MESSAGE_PREFIX = "#{Settings.app_name} access code:"
  let(:mobile_number) { Figaro.env.twilio_to_number }
  let(:user) { build(:user, mobile_number: mobile_number) }
  let(:instance) { described_class.new(user) }

  describe '#send_code' do
    before :each do
      allow_any_instance_of(described_class).to receive(:send_verification_sms).and_return(:sms)
      allow_any_instance_of(described_class).to receive(:make_verification_call).and_return(:call)
    end

    it 'sends sms to countries in Settings.verification_code_sms_countries' do
      Settings.verification_code_sms_countries.each do |cc_iso|
        user.mobile_number = sample_number(cc_iso.to_sym)
        expect(described_class.new(user).send_code).to eq :sms
      end
    end

    it 'calls countries not in Settings.verification_code_sms_countries' do
      user.mobile_number = "+919833695651"
      expect(described_class.new(user).send_code).to be :call
    end
  end

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

  describe '#make_verification_call' do
    subject { instance.make_verification_call }

    it 'makes a call to a valid number' do
      # FIXME: Alex, Note I set VCR.allow_http_connections_when_no_cassette=true for my own live testing you may wish to remove
      # instance.make_verification_call('+16502453537')
      pending('FIXME: Alex, please create cassette for valid outgoing call')
    end

    context 'on invalid number' do
      let(:mobile_number) { '+20227368296' }
      let(:error) { { code: 21_614, message: "'To' number is not a valid mobile number" } }
      it 'returns invalid number error' do
        pending('FIXME: Alex, please create a cassette for call to invalid number')
      end
    end

    context 'other error' do
      let(:mobile_number) { '+20227368296' }
      let(:error) { { code: 14_101, message: "'To' Attribute is Invalid" } }
      it 'returns other error' do
        pending('FIXME: Alex, please create a cassette for call to invalid number')
      end
    end
  end
end
