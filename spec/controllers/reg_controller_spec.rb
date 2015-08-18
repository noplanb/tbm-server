require 'rails_helper'

RSpec.describe RegController, type: :controller do
  describe 'GET #reg' do
    let(:mobile_number) { sample_number(:us) }
    let(:params) do
      { 'device_platform' => 'ios',
        'first_name' => 'Egypt',
        'last_name' => 'Test',
        'mobile_number' => mobile_number }
    end
    let(:user) { User.find_by_raw_mobile_number(mobile_number) }

    context 'success' do
      subject do
        VCR.use_cassette('twilio_message_with_success', erb: {
                           twilio_ssid: Figaro.env.twilio_ssid,
                           twilio_token: Figaro.env.twilio_token,
                           from: Figaro.env.twilio_from_number,
                           to: mobile_number }) do
          get :reg, params
        end
      end

      it 'returns http success' do
        subject
        expect(response).to have_http_status(:success)
      end

      it 'uses VerificationCodeSender#send_code' do
        expect_any_instance_of(VerificationCodeSender).to receive(:send_code)
        subject
      end

      context 'when user already exists' do
        let!(:user) { create(:user, params) }

        it 'returns http success' do
          subject
          expect(response).to have_http_status(:success)
        end
      end

      describe 'on success' do
        it 'returns mkey and auth' do
          subject
          expect(JSON.parse(response.body).keys).to include('status', 'auth', 'mkey')
        end

        context 'status' do
          specify do
            subject
            expect(user.status).to eq('registered')
          end
        end
      end

      context 'when device_platform is blank' do
        let(:params) do
          { 'first_name' => 'Egypt',
            'last_name' => 'Test',
            'mobile_number' => mobile_number }
        end

        it 'returns failure' do
          subject
          expect(JSON.parse(response.body).keys).to include('status', 'title', 'msg')
        end
      end

      context 'via SMS' do
        let(:mobile_number) { sample_number(:in) }
        subject do
          VCR.use_cassette('twilio_message_with_success', erb: {
                             twilio_ssid: Figaro.env.twilio_ssid,
                             twilio_token: Figaro.env.twilio_token,
                             from: Figaro.env.twilio_from_number,
                             to: mobile_number }) do
            get :reg, params.merge(via: :sms)
          end
        end

        it 'uses VerificationCodeSender#send_verification_sms' do
          expect_any_instance_of(VerificationCodeSender).to receive(:send_verification_sms)
          subject
        end
      end

      context 'via call' do
        let(:mobile_number) { sample_number(:us) }
        subject do
          VCR.use_cassette('twilio_call_with_success', erb: {
                             twilio_ssid: Figaro.env.twilio_ssid,
                             twilio_token: Figaro.env.twilio_token,
                             from: Figaro.env.twilio_from_number,
                             to: mobile_number,
                             url: '/call',
                             fallback_url: '/call_fallback'
                           }) do
            get :reg, params.merge(via: :call)
          end
        end

        it 'uses VerificationCodeSender#make_verification_call' do
          expect_any_instance_of(VerificationCodeSender).to receive(:make_verification_call)
          subject
        end
      end
    end

    describe 'on Twilio error' do
      let(:mobile_number) { sample_number(:gb) }
      let(:error) { { code: 21_614, message: "'To' number is not a valid mobile number" } }

      before do
        VCR.use_cassette('twilio_message_with_error', erb: {
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
          specify do
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
          specify do
            expect(JSON.parse(response.body)).to eq('status' => 'failure',
                                                    'title' => 'Bad mobile number',
                                                    'msg' => 'Please enter a valid country code and mobile number')
          end
        end
      end

      context 'status' do
        specify do
          expect(user.status).to eq('failed_to_register')
        end
      end
    end
  end

  describe 'GET #verify_code' do
    let(:user) { create(:ios_user, status: :registered) }
    let(:params) do
      user.attributes.slice('first_name', 'last_name',
                            'device_platform', 'verification_code')
    end
    before { user.reset_verification_code }

    specify do
      expect do
        authenticate_with_http_digest(user.mkey, user.auth) do
          get :verify_code, params
        end
      end.to change { user.reload.status }.from('registered').to('verified')
    end

    specify do
      authenticate_with_http_digest(user.mkey, user.auth) do
        get :verify_code, params
      end
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #get_friends' do
    let!(:user) { create(:user) }
    let!(:friend) { create(:user) }
    let!(:connection) { Connection.find_or_create(friend.id, user.id) }
    let(:data) do
      { 'id' => friend.id.to_s,
        'mkey' => friend.mkey,
        'first_name' => friend.first_name,
        'last_name' => friend.last_name,
        'mobile_number' => friend.mobile_number,
        'device_platform' => friend.device_platform,
        'emails' => friend.emails,
        'has_app' => 'false',
        'ckey' => connection.ckey,
        'cid' => connection.id,
        'connection_created_on' => connection.created_at,
        'connection_creator_mkey' => friend.mkey,
        'status' => connection.status }
    end

    before do
      authenticate_with_http_digest(user.mkey, user.auth) do
        get :get_friends
      end
    end

    specify do
      expect(response).to have_http_status(:ok)
    end

    specify do
      expect(response.body).to include_json(data.to_json)
    end
  end
end
