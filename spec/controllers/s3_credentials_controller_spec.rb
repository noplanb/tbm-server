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

    context 'when HTTP Digest auth credentials are valid' do
      let(:user) { create(:user) }

      before do
        s3_credential.update_credentials(region: 'us-west-1',
                                         bucket: 'bucket',
                                         access_key: 'access_key',
                                         secret_key: 'secret_key')
      end

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

  describe 'GET #index' do
    context 'when not authenticated' do
      before { get :index }
      specify { is_expected.to respond_with(:unauthorized) }
    end

    context 'when authenticated' do
      before { authenticate_with_http_basic }
      before { get :index }
      specify { expect(response).to redirect_to(assigns(:s3_credential)) }
    end
  end

  describe 'GET #show' do
    let(:params) { { id: s3_credential.id } }
    context 'when not authenticated' do
      before { get :show, params }
      specify { is_expected.to respond_with(:unauthorized) }
    end

    context 'when authenticated' do
      before { authenticate_with_http_basic }
      before { get :show, params }
      specify { is_expected.to respond_with(:success) }
      specify { expect(assigns(:s3_credential)).to eq(s3_credential) }
    end
  end

  describe 'GET #edit' do
    let(:params) { { id: s3_credential.id } }
    context 'when not authenticated' do
      before { get :edit, params }
      specify { is_expected.to respond_with(:unauthorized) }
    end

    context 'when authenticated' do
      before { authenticate_with_http_basic }
      before { get :edit, params }
      specify { is_expected.to respond_with(:success) }
      specify { expect(assigns(:s3_credential)).to eq(s3_credential) }
    end
  end

  describe 'PATCH #update' do
    before do
      s3_credential.region = 'us-west-1'
      s3_credential.bucket = 'bucket'
      s3_credential.access_key = 'access_key'
      s3_credential.secret_key = 'secret_key'
      s3_credential.save
    end

    let(:params) { { id: s3_credential.id, s3_credential: { region: 'us-east-1' } } }
    let(:invalid_params) { { id: s3_credential.id, s3_credential: { region: 'ololo!' } } }

    context 'when not authenticated' do
      before { patch :update, params }
      specify { is_expected.to respond_with(:unauthorized) }
    end

    context 'when authenticated' do
      before { authenticate_with_http_basic }

      context 'with valid params' do
        specify do
          patch :update, params
          expect(response).to redirect_to(assigns(:s3_credential))
        end

        specify do
          expect { patch :update, params }.to change { s3_credential.reload.region }.from('us-west-1').to('us-east-1')
        end
      end

      context 'with invalid params' do
        specify do
          patch :update, invalid_params
          is_expected.to render_template(:edit)
        end
      end
    end
  end
end
