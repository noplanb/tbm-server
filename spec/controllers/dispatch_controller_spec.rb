require 'rails_helper'

RSpec.describe DispatchController, type: :controller do
  let(:msg) { "\n#\n\nTestError: testing dispatch forwarding notification\n2015-03-30 Log1\n2015-03-30 Log2" }
  let(:error_message) { 'TestError: testing dispatch forwarding notification' }

  describe '#error_message' do
    subject { controller.error_message(msg) }
    it { is_expected.to eq(error_message) }

    context 'when msg without title' do
      let(:msg) { "| Friends |\n| Name     | ID       | Has app  | IV !v co | OV ID    | OV statu | Last eve | Has thum | Download |\n| ????? iO | 19       | true     | 0        |          | 0        | IN       | false    | false    |\n\n| ????? iOS |\n\n" }
      it { is_expected.to eq('Dispatch Message') }
    end
  end

  describe 'POST #post_dispatch' do
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
        expect_any_instance_of(Rollbar::Notifier).to receive(:error).with(error_message)
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
        expect_any_instance_of(Rollbar::Notifier).to receive(:error).with(error_message)
        authenticate_with_http_digest(user.mkey, user.auth) do
          post :post_dispatch, msg: msg
        end
      end
    end
  end
end
