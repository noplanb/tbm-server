require 'rails_helper'

RSpec.describe S3CredentialsController, type: :controller do
  let(:s3_credential) { S3Credential.instance }

  describe 'GET #info' do
    context 'when HTTP Digest auth credentials are invalid' do
      before do
        authenticate_with_http_digest('invalid_login', 'invalid_password') do
          get :info
        end
      end

      specify { is_expected.to respond_with(:unauthorized) }
    end

    context 'when HTTP Digest auth credentials are missing' do
      before { get :info }

      specify { is_expected.to respond_with(:unauthorized) }
    end

    context 'when credential are valid' do
      before do
        s3_credential.region = 'us-west-1'
        s3_credential.bucket = 'bucket'
        s3_credential.access_key = 'access_key'
        s3_credential.secret_key = 'secret_key'
        s3_credential.save
      end

      let!(:user) { create(:user) }

      before do
        authenticate_with_http_digest(user.mkey, user.auth) do
          get :info
        end
      end

      specify { is_expected.to respond_with(:success) }
      specify do
        expect(JSON.parse(response.body)).to eq('status' => 'success',
                                                'region' => 'us-west-1',
                                                'bucket' => 'bucket',
                                                'access_key' => 'access_key',
                                                'secret_key' => 'secret_key')
      end
    end
  end
end
