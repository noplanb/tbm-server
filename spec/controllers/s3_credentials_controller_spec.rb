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

      it { is_expected.to respond_with(:unauthorized) }
    end

    context 'when HTTP Digest auth credentials are missing' do
      before { get :info }

      it { is_expected.to respond_with(:unauthorized) }
    end

    context 'when credential are valid' do
      let!(:user) { create(:user) }

      before do
        authenticate_with_http_digest(user.mkey, user.auth) do
          get :info
        end
      end

      it { is_expected.to respond_with(:success) }
    end
  end
end
