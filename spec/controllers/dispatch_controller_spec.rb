require 'rails_helper'

RSpec.describe DispatchController, type: :controller do

  describe "POST #post_dispatch" do
    let(:msg) { "TestError: testing Airbrake notification\nBacktrace" }

    context 'iOS' do
      let(:user) { create(:ios_user) }

      it 'returns success response' do
        authenticate_with_http_digest(user.mkey, user.auth) do
          post :post_dispatch, msg: msg
        end
        expect(response).to be_success
      end

      it 'notifies airbrake' do
        expect(Airbrake).to receive(:notify).with(error_message: 'TestError: testing Airbrake notification',
          backtrace: msg,
          api_key: Figaro.env.ios_airbrake_api_key)
        authenticate_with_http_digest(user.mkey, user.auth) do
          post :post_dispatch, msg: msg
        end
      end
    end

    context 'Android' do
      let(:user) { create(:android_user) }

      it 'returns success response' do
        authenticate_with_http_digest(user.mkey, user.auth) do
          post :post_dispatch, msg: msg
        end
        expect(response).to be_success
      end

      it 'notifies airbrake' do
        expect(Airbrake).to receive(:notify).with(error_message: 'TestError: testing Airbrake notification',
          backtrace: msg,
          api_key: Figaro.env.android_airbrake_api_key)
        authenticate_with_http_digest(user.mkey, user.auth) do
          post :post_dispatch, msg: msg
        end
      end
    end

  end

end
