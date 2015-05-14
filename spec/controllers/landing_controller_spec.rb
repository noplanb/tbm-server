require 'rails_helper'

RSpec.describe LandingController, type: :controller do
  let(:inviter) { create(:user) }

  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #invite' do
    subject { get :invite, id: inviter.id }

    it 'returns http success' do
      subject
      expect(response).to have_http_status(:success)
    end

    context 'iPhone' do
      before { request.user_agent = 'Mozilla/5.0 (iPhone; CPU iPhone OS 8_3 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Version/8.0 Mobile/12F70 Safari/600.1.4' }

      specify do
        subject
        expect(response).to redirect_to(Settings.iphone_store_url)
      end
    end

    context 'Android' do
      before { request.user_agent = 'Android 5.0' }

      specify do
        subject
        expect(response).to redirect_to(Settings.android_store_url)
      end
    end

    context 'Windows Phone' do
      before do
        request.user_agent = 'Mozilla/5.0 (Mobile; Windows Phone 8.1;
        Android 4.0; ARM; Trident/7.0; Touch; rv:11.0; IEMobile/11.0;
        NOKIA; Lumia 520; ANZ915) like iPhone OS 7_0_3
        Mac OS X AppleWebKit/537 (KHTML, like Gecko) Mobile Safari/537'
      end

      specify do
        expect(Rollbar).to receive(:warning)
        subject
      end

      specify do
        subject
        expect(response).to be_redirect
      end
    end

    context 'iPhone & Android' do
      before { request.user_agent = 'Mozilla/5.0 (iPhone; CPU iPhone OS 8_3 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Version/8.0 Mobile/12F70 Safari/600.1.4 Android 5.0' }

      specify do
        expect(Rollbar).to receive(:warning)
        subject
      end

      specify do
        subject
        expect(response).to redirect_to('/')
      end
    end

    context 'Unsupported' do
      before { request.user_agent = 'Unsupported' }

      specify do
        expect(Rollbar).to_not receive(:warning)
        subject
      end

      specify do
        subject
        expect(response).to render_template(:invite)
      end
    end

    context 'Unsupported Mobile' do
      before { request.user_agent = 'Unsupported Mobile' }

      specify do
        expect(Rollbar).to receive(:warning)
        subject
      end

      specify do
        subject
        expect(response).to be_redirect
      end
    end
  end
end
