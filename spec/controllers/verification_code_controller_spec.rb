require 'rails_helper'

RSpec.configure do |c|
  c.include TwimlHelpers
end

RSpec.describe VerificationCodeController, type: :controller do

  describe 'GET #say_code' do
    let(:valid_mobile) { '+16507800144' }
    let(:params){ {} }

    before do
      create(User, { mobile_number: valid_mobile })
      get :say_code, params
    end

    context 'user found with to: mobile number' do
      let(:params){ { To: valid_mobile } }
      it('says verification code') { expect(twiml_says_verification_code? response.body) }
    end

    context 'to: not in params' do
      it('says error') do
        pending('Alex: why doesnt expect rollbar error work')
        # expect(Rollbar).to receive(:error)
        expect(twiml_says_error? response.body)
      end
    end

    context 'no user found for to: number' do
      let(:params){ { To: '+6505551212' } }
      it('says error') do
        pending('Alex: why doesnt expect rollbar error work')
        # expect(Rollbar).to receive(:error)
        expect(twiml_says_error? response.body)
      end
    end

    context 'no user found for to: number' do
      it('says error') do
        pending('Alex: why doesnt expect rollbar error work')
        # expect(Rollbar).to receive(:error)
        expect(twiml_says_error? response.body)
      end
    end

  end


  describe '#spaced_code' do
    subject { controller.instance_eval{ spaced_code('1234') } }
    it { is_expected.to eq(' 1 2 3 4 ') }
  end

end