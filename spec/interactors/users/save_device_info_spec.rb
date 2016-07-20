require 'rails_helper'

RSpec.describe Users::SaveDeviceInfo do
  let(:user) { create(:user) }
  let(:default_device) { %w(android 168) }
  let(:params) { default_params }
  let(:default_params) do
    { user: user,
      platform: default_device.first,
      version: default_device.last }
  end

  describe '.run' do
    def create_user(platform = nil, version = nil)
      create(:user, device_platform: platform, app_version: version)
    end

    let(:user_device_info) do
      user.reload.tap { |u| return [u.device_platform.to_s, u.app_version.to_s] }
    end

    subject { described_class.run(params) }

    context 'when user has no device info' do
      it { expect(subject).to be_valid }
      it { expect(user).to receive(:update_attributes); subject }
      it { subject; expect(user_device_info).to eq(%w(android 168))}
    end

    context 'when user has old device info' do
      let(:user) { create_user('android', '165') }

      it { expect(subject).to be_valid }
      it { expect(user).to receive(:update_attributes); subject }
      it { subject; expect(user_device_info).to eq(%w(android 168))}
    end

    context 'when user has same device info' do
      let(:user) { create_user(*default_device) }

      it { expect(subject).to be_valid }
      it { expect(user).to_not receive(:update_attributes); subject }
      it { subject; expect(user_device_info).to eq(%w(android 168))}
    end

    context 'when device platform is not supported' do
      let(:params) { default_params.merge(platform: 'windows') }

      it { expect(subject).to_not be_valid }
      it { expect(user).to_not receive(:update_attributes); subject }
      it { subject; expect(user_device_info).to eq(['', ''])}
    end
  end
end
