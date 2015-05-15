require 'rails_helper'

RSpec.describe VersionController, type: :controller do
  describe 'GET #check_compatibility' do
    subject { get :check_compatibility, device_platform: device_platform, version: version }

    context 'ios' do
      let(:device_platform) { :ios }

      context '21' do
        let(:version) { '21' }

        specify do
          subject
          expect(json_response).to eq('result' => 'update_required')
        end
      end

      context '22' do
        let(:version) { '22' }

        specify do
          subject
          expect(json_response).to eq('result' => 'current')
        end
      end
    end

    context 'android' do
      let(:device_platform) { :android }

      context '41' do
        let(:version) { '41' }

        specify do
          subject
          expect(json_response).to eq('result' => 'update_required')
        end
      end

      context '42' do
        let(:version) { '42' }

        specify do
          subject
          expect(json_response).to eq('result' => 'current')
        end
      end
    end

    context 'empty' do
      let(:device_platform) {}

      context '21' do
        let(:version) { '21' }

        specify do
          subject
          expect(json_response).to eq('result' => 'update_required')
        end
      end

      context '22' do
        let(:version) { '22' }

        specify do
          subject
          expect(json_response).to eq('result' => 'current')
        end
      end
    end
  end
end
