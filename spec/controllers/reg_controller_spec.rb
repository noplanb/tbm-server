require 'rails_helper'

RSpec.describe RegController, type: :controller do
  describe 'GET #reg' do
    let(:params) do
      { 'device_platform' => 'ios',
        'first_name' => 'Egypt',
        'last_name' => 'Test',
        'mobile_number' => '+20227368296' }
    end
    let(:error) { { code: 21614, message: "'To' number is not a valid mobile number" } }

    before do
      VCR.use_cassette('twilio_error_response', erb: { twilio_ssid: Figaro.env.twilio_ssid, twilio_token: Figaro.env.twilio_token }.merge(error)) do
        get :reg, params
      end
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    [{ code: 14101, message: "'To' Attribute is Invalid" }].each do |error|
      context "#{error[:code]}: #{error[:message]}" do
        let(:error) { error }
        it do
          expect(JSON.parse(response.body)).to eq('status' => 'failure',
                                                'title' => 'Bad phone number',
                                                'msg' => "'To' Attribute is Invalid")
        end
      end
    end

    [
      { code: 21211, message: "Invalid 'To' Phone Number" },
      { code: 21214, message: "'To' phone number cannot be reached" },
      { code: 21217, message: "Phone number does not appear to be valid" },
      { code: 21219, message: "'To' phone number not verified" },
      { code: 21401, message: "Invalid Phone Number" },
      { code: 21407, message: "This Phone Number type does not support SMS or MMS" },
      { code: 21421, message: "PhoneNumber is invalid" },
      { code: 21614, message: "'To' number is not a valid mobile number" }
    ].each do |error|
      context "#{error[:code]}: #{error[:message]}" do
        let(:error) { error }
        it do
          expect(JSON.parse(response.body)).to eq('status' => 'failure',
                                                  'title' => 'Bad phone number',
                                                  'msg' => 'Please enter a valid country code and phone number')
        end
      end
    end
  end
end
