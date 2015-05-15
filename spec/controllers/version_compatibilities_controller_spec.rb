require 'rails_helper'

RSpec.describe VersionCompatibilitiesController, type: :controller do
  let(:version_compatibility) { VersionCompatibility.instance }

  describe 'GET #index' do
    context 'when not authenticated' do
      before { get :index }
      specify { is_expected.to respond_with(:unauthorized) }
    end

    context 'when authenticated' do
      before { authenticate_with_http_basic }
      before { get :index }
      specify { expect(response).to redirect_to(assigns(:version_compatibility)) }
    end
  end

  describe 'GET #show' do
    let(:params) { { id: version_compatibility.id } }
    context 'when not authenticated' do
      before { get :show, params }
      specify { is_expected.to respond_with(:unauthorized) }
    end

    context 'when authenticated' do
      before { authenticate_with_http_basic }
      before { get :show, params }
      specify { is_expected.to respond_with(:success) }
      specify { expect(assigns(:version_compatibility)).to eq(version_compatibility) }
    end
  end

  describe 'GET #edit' do
    let(:params) { { id: version_compatibility.id } }
    context 'when not authenticated' do
      before { get :edit, params }
      specify { is_expected.to respond_with(:unauthorized) }
    end

    context 'when authenticated' do
      before { authenticate_with_http_basic }
      before { get :edit, params }
      specify { is_expected.to respond_with(:success) }
      specify { expect(assigns(:version_compatibility)).to eq(version_compatibility) }
    end
  end

  describe 'PATCH #update' do
    before do
      version_compatibility.ios_mandatory_upgrade_version_threshold = 0
      version_compatibility.ios_optional_upgrade_version_threshold = 0
      version_compatibility.android_mandatory_upgrade_version_threshold = 0
      version_compatibility.android_optional_upgrade_version_threshold = 0
      version_compatibility.save
    end

    let(:params) do
      { id: version_compatibility.id, version_compatibility: {
        ios_mandatory_upgrade_version_threshold: '10',
        ios_optional_upgrade_version_threshold: '20',
        android_mandatory_upgrade_version_threshold: '10',
        android_optional_upgrade_version_threshold: '20'
      } }
    end

    context 'when not authenticated' do
      before { patch :update, params }
      specify { is_expected.to respond_with(:unauthorized) }
    end

    context 'when authenticated' do
      before { authenticate_with_http_basic }

      context 'with valid params' do
        specify do
          patch :update, params
          expect(response).to redirect_to(assigns(:version_compatibility))
        end

        specify do
          expect { patch :update, params }.to change {
             version_compatibility.reload.ios_mandatory_upgrade_version_threshold
          }.from(0).to(10)
        end

        specify do
          expect { patch :update, params }.to change {
             version_compatibility.reload.ios_optional_upgrade_version_threshold
          }.from(0).to(20)
        end

        specify do
          expect { patch :update, params }.to change {
             version_compatibility.reload.android_mandatory_upgrade_version_threshold
          }.from(0).to(10)
        end

        specify do
          expect { patch :update, params }.to change {
             version_compatibility.reload.android_optional_upgrade_version_threshold
          }.from(0).to(20)
        end
      end
    end
  end
end
