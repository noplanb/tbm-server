require 'rails_helper'

RSpec.describe VersionCompatibility, type: :model do
  let(:instance) { described_class.instance }

  context 'attributes' do
    subject { described_class.credential_attributes }
    specify do
      is_expected.to eq([:ios_mandatory_upgrade_version_threshold,
                         :ios_optional_upgrade_version_threshold,
                         :android_mandatory_upgrade_version_threshold,
                         :android_optional_upgrade_version_threshold])
    end
  end

  context 'validations' do
    it { is_expected.to validate_presence_of(:ios_mandatory_upgrade_version_threshold) }
    it { is_expected.to validate_presence_of(:android_mandatory_upgrade_version_threshold) }
  end

  describe '#compatibility' do
    subject { instance.compatibility(device_platform, version) }

    before do
      instance.ios_mandatory_upgrade_version_threshold = '1.0.0'
      instance.ios_optional_upgrade_version_threshold = '1.2.0'
      instance.android_mandatory_upgrade_version_threshold = '2.0.0'
      instance.android_optional_upgrade_version_threshold = '2.2.0'
      instance.save
    end

    context 'unsupported' do
      let(:device_platform) { :unsupported }
      let(:version) {}

      it { is_expected.to eq(:unsupported) }
    end

    context 'ios' do
      let(:device_platform) { :ios }

      context '0.9.0' do
        let(:version) { '0.9.0' }
        it { is_expected.to eq(:update_required) }
      end

      context '1.1.0' do
        let(:version) { '1.1.0' }
        it { is_expected.to eq(:update_optional) }
      end

      context '1.2.0' do
        let(:version) { '1.2.0' }
        it { is_expected.to eq(:current) }
      end
    end

    context 'android' do
      let(:device_platform) { :android }

      context '1.9.0' do
        let(:version) { '1.9.0' }
        it { is_expected.to eq(:update_required) }
      end

      context '2.1.0' do
        let(:version) { '2.1.0' }
        it { is_expected.to eq(:update_optional) }
      end

      context '2.2.0' do
        let(:version) { '2.2.0' }
        it { is_expected.to eq(:current) }
      end
    end
  end
end
