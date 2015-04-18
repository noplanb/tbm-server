require 'rails_helper'

RSpec.describe VerificationCodeController, type: :controller do
  describe 'GET #say_code' do
    let(:valid_mobile) { '+16507800144' }
    let(:params) { {} }
    let!(:user) { create(:user, mobile_number: valid_mobile) }

    context 'user found with to: mobile number' do
      let(:params) { { To: valid_mobile } }
      specify do
        get :say_code, params
        expect(response.body).to say_twiml_verification_code
      end
    end

    context 'to: not in params' do
      specify do
        get :say_code, params
        expect(response.body).to say_twiml_error
      end
      specify do
        expect(Rollbar).to receive(:error)
        get :say_code, params
      end
    end

    context 'no user found for to: number' do
      let(:params) { { To: '+6505551212' } }
      specify do
        get :say_code, params
        expect(response.body).to say_twiml_error
      end
      specify do
        expect(Rollbar).to receive(:error)
        get :say_code, params
      end
    end

    context 'no user found for to: number' do
      specify do
        get :say_code, params
        expect(response.body).to say_twiml_error
      end
      specify do
        expect(Rollbar).to receive(:error)
        get :say_code, params
      end
    end
  end

  describe '#spaced_code' do
    subject { controller.instance_eval { spaced_code('1234') } }
    it { is_expected.to eq(' 1 2 3 4 ') }
  end
end
