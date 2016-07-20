require 'rails_helper'

RSpec.describe VersionController, type: :controller do
  include_context 'user authentication'

  let(:user) { create(:user) }

  describe 'GET #check_compatibility' do
    before do
      authenticate_user do
        get :check_compatibility,
            device_platform: device_platform, version: version
      end
    end

    subject do
      user.reload.tap { |u| return [u.device_platform, u.app_version] }
    end

    context 'ios' do
      let(:device_platform) { :ios }

      context '21' do
        let(:version) { '21' }

        it { expect(json_response).to eq('result' => 'update_required') }
        it { is_expected.to eq([:ios, '21']) }
      end

      context '22' do
        let(:version) { '22' }

        it { expect(json_response).to eq('result' => 'current') }
        it { is_expected.to eq([:ios, '22']) }
      end
    end

    context 'android' do
      let(:device_platform) { :android }

      context '41' do
        let(:version) { '41' }

        it { expect(json_response).to eq('result' => 'update_required') }
        it { is_expected.to eq([:android, '41']) }
      end

      context '42' do
        let(:version) { '42' }

        it { expect(json_response).to eq('result' => 'current') }
        it { is_expected.to eq([:android, '42']) }
      end
    end

    context 'empty' do
      let(:device_platform) {}

      context '21' do
        let(:version) { '21' }

        it { expect(json_response).to eq('result' => 'unsupported') }
        it { is_expected.to eq([nil, nil]) }
      end

      context '22' do
        let(:version) { '22' }

        it { expect(json_response).to eq('result' => 'unsupported') }
        it { is_expected.to eq([nil, nil]) }
      end
    end
  end
end
