require 'rails_helper'

RSpec.describe Users::SaveClientInfo do
  let(:user) { create(:user) }
  let(:default_info) { %w(android 168) }
  let(:params) { default_params }
  let(:default_params) do
    { user: user,
      device_platform: default_info.first,
      app_version: default_info.last }
  end
  let(:android_vendor) { 'Samsung\nGT-S9870\n6.0.1' }

  describe '.run' do
    def create_user(platform = nil, version = nil, info = nil)
      create(:user,
        device_platform: platform,
        device_info: info,
        app_version: version)
    end

    let(:user_device_info) { user.reload.device_info }
    let(:user_platform_version) do
      user.reload.tap do |u|
        return [u.device_platform.to_s, u.app_version.to_s]
      end
    end

    subject { described_class.run(params) }

    context 'when user has no client info' do
      it { expect(subject).to be_valid }
      it { subject; expect(user_platform_version).to eq(%w(android 168))}
      it { expect(user).to receive(:update_attributes); subject }
    end

    context 'when user has old client info' do
      let(:user) { create_user('android', '165') }

      it { expect(subject).to be_valid }
      it { subject; expect(user_platform_version).to eq(%w(android 168))}
      it { expect(user).to receive(:update_attributes); subject }
    end

    context 'when user has same client info' do
      let(:user) { create_user(*default_info, android_vendor) }

      context 'when device_info is persisted in inputs' do
        let(:params) { default_params.merge(device_info: android_vendor) }

        it { expect(subject).to be_valid }
        it { subject; expect(user_platform_version).to eq(%w(android 168))}
        it { subject; expect(user_device_info).to eq(android_vendor)}
        it { expect(user).to_not receive(:update_attributes); subject }
      end

      context 'when device_info is not persisted in inputs' do
        it { expect(subject).to be_valid }
        it { subject; expect(user_platform_version).to eq(%w(android 168))}
        it { subject; expect(user_device_info).to eq(android_vendor)}
        it { expect(user).to receive(:update_attributes); subject }
      end
    end

    context 'when device platform is not supported' do
      let(:params) { default_params.merge(device_platform: 'windows') }

      it { expect(subject).to_not be_valid }
      it { subject; expect(user_platform_version).to eq(['', ''])}
      it { expect(user).to_not receive(:update_attributes); subject }
    end
  end
end
