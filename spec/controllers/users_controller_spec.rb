require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  before { authenticate_with_http_basic }
  let(:user) { create(:user) }
  let(:sender) { create(:user) }
  let!(:connection) { Connection.find_or_create(user.id, sender.id) }
  let!(:push_user) do
    PushUser.create_or_update(mkey: user.mkey,
                              device_platform: user.device_platform,
                              push_token: 'push_token')
  end

  describe 'GET #receive_test_video' do
    let!(:s3_credential) do
      S3Credential.instance.update_credentials(region: 'us-west-1',
                                               bucket: 'bucket',
                                               access_key: 'access_key',
                                               secret_key: 'secret_key')
    end
    let(:params) { { id: user.id, sender_id: sender.id } }
    before do
      allow(subject).to receive(:s3_object).and_return(double('AWS::S3::Object', write: true))
    end
    before { get :receive_test_video, params }

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end
end
