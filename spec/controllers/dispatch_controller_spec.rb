require 'rails_helper'

RSpec.describe DispatchController, type: :controller do
  describe 'POST #post_dispatch' do
    let(:msg) { "\n#\n\nTestError: testing dispatch forwarding notification\n2015-03-30 Log1\n2015-03-30 Log2" }
    let(:error_message) { 'TestError: testing dispatch forwarding notification' }
    let(:scope) { { person: {
          id: user.id,
          username: user.name,
          email: user.mobile_number }} }

    context 'iOS' do
      let(:user) { create(:ios_user) }
      let(:access_token) { Figaro.env.ios_rollbar_access_token }

      it 'returns success response' do
        authenticate_with_http_digest(user.mkey, user.auth) do
          post :post_dispatch, msg: msg
        end
        expect(response).to be_success
      end

      it 'notifies Rollbar', pending: 'FIXME: Rollbar.scope returns nil' do
        expect(Rollbar).to receive(:scope).with(scope)
        expect_any_instance_of(Rollbar::Configuration).to receive(:access_token).with(access_token)
        expect_any_instance_of(Rollbar::Notifier).to receive(:error).with(error_message, report: msg)
        authenticate_with_http_digest(user.mkey, user.auth) do
          post :post_dispatch, msg: msg
        end
      end
    end

    context 'Android' do
      let(:user) { create(:android_user) }
      let(:access_token) { Figaro.env.android_rollbar_access_token }

      it 'returns success response' do
        authenticate_with_http_digest(user.mkey, user.auth) do
          post :post_dispatch, msg: msg
        end
        expect(response).to be_success
      end

      it 'notifies Rollbar', pending: 'FIXME: Rollbar.scope returns nil' do
        expect(Rollbar).to receive(:scope).with(scope)
        expect_any_instance_of(Rollbar::Configuration).to receive(:access_token).with(access_token)
        expect_any_instance_of(Rollbar::Notifier).to receive(:error).with(error_message, report: msg)
        authenticate_with_http_digest(user.mkey, user.auth) do
          post :post_dispatch, msg: msg
        end
      end
    end
  end
end
