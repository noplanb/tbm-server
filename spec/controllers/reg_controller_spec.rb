require 'rails_helper'

RSpec.describe RegController, type: :controller do
  describe 'GET #reg' do
    let(:params) { }
    before { get :reg, params }

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    context "21614: 'To' number is not a valid mobile number" do
      let(:params) do
        { 'device_platform' => 'ios',
          'first_name' => 'Egypt',
          'last_name' => 'Test',
          'mobile_number' => '+20227368296' }
      end
      it do
        expect(JSON.parse(response.body)).to eq('status' => 'failure',
                                                'title' => 'Bad phone number',
                                                'msg' => 'Please enter a valid country code and phone number')
      end
    end
  end
end
