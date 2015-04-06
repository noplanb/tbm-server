require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  before { authenticate_with_http_basic }
  let(:user) { create(:user) }
  let(:sender) { create(:user) }
  let!(:connection) { Connection.find_or_create(user.id, sender.id) }
  let!(:s3_credential) do
    S3Credential.instance.update_credentials(region: 'us-west-1',
                                             bucket: 'bucket',
                                             access_key: 'access_key',
                                             secret_key: 'secret_key')
  end
  before { allow(subject).to receive(:s3_object).and_return(double('AWS::S3::Object', write: true)) }

  describe 'GET #receive_test_video' do
    let(:params) { { id: user.id, sender_id: sender.id } }
    before { allow_any_instance_of(PushUser).to receive(:send_notification).and_return(true) }

    context 'when push user exists' do
      let!(:push_user) do
        PushUser.create_or_update(mkey: user.mkey,
                                  device_platform: user.device_platform,
                                  push_token: 'push_token')
      end
      before { get :receive_test_video, params }

      specify do
        expect(response).to redirect_to(user)
      end
    end

    context 'when push user not exists' do
      specify  do
        expect { get :receive_test_video, params }.to raise_error(ActionController::RoutingError)
      end
    end
  end
end
