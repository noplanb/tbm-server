require 'rails_helper'
RSpec.describe VerificationCodeController, type: :controller do

  describe 'GET #say_code' do
    before { get :say_code, params }

    it 'Sends error twml when !params[]' do
      debugger
      let(:params){ {foo:'foobar'} }
    end


  end


  describe '#spaced_code' do
    subject { controller.instance_eval{ spaced_code('1234') } }
    it { is_expected.to eq('1 2 3 4') }
  end

end