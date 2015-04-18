require 'rails_helper'

RSpec.describe RegController, type: :controller do
  describe 'GET #reg' do
    let(:mobile_number) { '+1 650 245 3537' }
    let(:params) do
      { 'device_platform' => 'ios',
        'first_name' => 'Egypt',
        'last_name' => 'Test',
        'mobile_number' => mobile_number }
    end

    it 'returns http success' do
      VCR.use_cassette('twilio_success_response', erb: {
                         twilio_ssid: Figaro.env.twilio_ssid,
                         twilio_token: Figaro.env.twilio_token,
                         from: Figaro.env.twilio_from_number,
                         to: mobile_number }) do
        get :reg, params
      end
      expect(response).to have_http_status(:success)
    end

    context 'when user already exists' do
      let!(:user) { create(:user, params) }

      it 'returns http success' do
        VCR.use_cassette('twilio_success_response', erb: {
                           twilio_ssid: Figaro.env.twilio_ssid,
                           twilio_token: Figaro.env.twilio_token,
                           from: Figaro.env.twilio_from_number,
                           to: mobile_number }) do
          get :reg, params
        end
        expect(response).to have_http_status(:success)
      end
    end

    describe 'on success' do
      it 'returns mkey and auth' do
        VCR.use_cassette('twilio_success_response', erb: {
                           twilio_ssid: Figaro.env.twilio_ssid,
                           twilio_token: Figaro.env.twilio_token,
                           from: Figaro.env.twilio_from_number,
                           to: mobile_number }) do
          get :reg, params
        end
        expect(JSON.parse(response.body).keys).to include('status', 'auth', 'mkey')
      end
    end

    describe 'on Twilio error' do
      let(:mobile_number) { '+20227368296' }
      let(:error) { { code: 21_614, message: "'To' number is not a valid mobile number" } }

      before do
        VCR.use_cassette('twilio_error_response', erb: {
          twilio_ssid: Figaro.env.twilio_ssid,
          twilio_token: Figaro.env.twilio_token,
          from: Figaro.env.twilio_from_number,
          to: mobile_number }.merge(error)) do
          get :reg, params
        end
      end

      [{ code: 14_101, message: "'To' Attribute is Invalid" }].each do |error|
        context "#{error[:code]}: #{error[:message]}" do
          let(:error) { error }
          it do
            expect(JSON.parse(response.body)).to eq('status' => 'failure',
                                                    'title' => 'Sorry!',
                                                    'msg' => 'We encountered a problem on our end. We will fix shortly. Please try again later.')
          end
        end
      end

      [
        { code: 21_211, message: "Invalid 'To' Phone Number" },
        { code: 21_214, message: "'To' phone number cannot be reached" },
        { code: 21_217, message: 'Phone number does not appear to be valid' },
        { code: 21_219, message: "'To' phone number not verified" },
        { code: 21_401, message: 'Invalid Phone Number' },
        { code: 21_407, message: 'This Phone Number type does not support SMS or MMS' },
        { code: 21_421, message: 'PhoneNumber is invalid' },
        { code: 21_614, message: "'To' number is not a valid mobile number" }
      ].each do |error|
        context "#{error[:code]}: #{error[:message]}" do
          let(:error) { error }
          it do
            expect(JSON.parse(response.body)).to eq('status' => 'failure',
                                                    'title' => 'Bad mobile number',
                                                    'msg' => 'Please enter a valid country code and mobile number')
          end
        end
      end
    end
  end
end
