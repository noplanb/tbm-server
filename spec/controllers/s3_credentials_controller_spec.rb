require 'rails_helper'

RSpec.describe S3CredentialsController, type: :controller do
  let(:s3_credential) { S3Credential::Videos.instance }

  describe 'GET #info' do
    context 'when HTTP Digest auth credentials are invalid' do
      before do
        authenticate_with_http_digest('invalid_login', 'invalid_password') do
          get :info
        end
      end

      it { is_expected.to respond_with(:unauthorized) }
    end

    context 'when HTTP Digest auth credentials are missing' do
      before { get :info }

      it { is_expected.to respond_with(:unauthorized) }
    end

    context 'when HTTP Digest auth credentials are valid' do
      let(:user) { create(:user) }

      before do
        expected = {
          region: 'us-west-1',
          bucket: 'bucket',
          access_key: 'access_key',
          secret_key: 'secret_key' }
        s3_credential.update_credentials(expected)
      end

      before do
        authenticate_with_http_digest(user.mkey, user.auth) do
          get :info, id: :videos
        end
      end

      it { is_expected.to respond_with(:success) }
      it do
        expected = {
          'status' => 'success',
          'region' => 'us-west-1',
          'bucket' => 'bucket',
          'access_key' => 'access_key',
          'secret_key' => 'secret_key' }
        expect(JSON.parse(response.body)).to eq(expected)
      end
    end
  end
end
