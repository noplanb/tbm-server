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

    it { is_expected.to validate_numericality_of(:ios_mandatory_upgrade_version_threshold).only_integer }
    it { is_expected.to validate_numericality_of(:ios_optional_upgrade_version_threshold).only_integer.allow_nil }
    it { is_expected.to validate_numericality_of(:android_mandatory_upgrade_version_threshold).only_integer }
    it { is_expected.to validate_numericality_of(:android_optional_upgrade_version_threshold).only_integer.allow_nil }
  end

  describe 'defaults' do
    context 'ios_mandatory_upgrade_version_threshold' do
      subject { instance.ios_mandatory_upgrade_version_threshold }
      it { is_expected.to eq(22) }
    end

    context 'android_mandatory_upgrade_version_threshold' do
      subject { instance.android_mandatory_upgrade_version_threshold }
      it { is_expected.to eq(42) }
    end
  end

  describe '#update_credentials' do
    before { instance.update_credentials(credentials) }

    context 'when values as strings' do
      let(:credentials) do
        { 'ios_mandatory_upgrade_version_threshold' => '10',
          'ios_optional_upgrade_version_threshold' => '15',
          'android_mandatory_upgrade_version_threshold' => '20',
          'android_optional_upgrade_version_threshold' => '25' }
      end

      describe 'cred' do
        subject { instance.cred }
        specify do
          is_expected.to eq('ios_mandatory_upgrade_version_threshold' => 10,
                            'ios_optional_upgrade_version_threshold' => 15,
                            'android_mandatory_upgrade_version_threshold' => 20,
                            'android_optional_upgrade_version_threshold' => 25)
        end
      end
    end
  end

  describe '#compatibility' do
    subject { instance.compatibility(device_platform, version) }

    context 'unsupported' do
      let(:device_platform) { :unsupported }
      let(:version) {}

      it { is_expected.to eq(:unsupported) }
    end

    context 'when VersionCompatibility is not set' do
      context 'ios' do
        let(:device_platform) { :ios }

        context '21' do
          let(:version) { '21' }
          it { is_expected.to eq(:update_required) }
        end

        context '22' do
          let(:version) { '22' }
          it { is_expected.to eq(:current) }
        end
      end

      context 'android' do
        let(:device_platform) { :android }

        context '41' do
          let(:version) { '41' }
          it { is_expected.to eq(:update_required) }
        end

        context '42' do
          let(:version) { '42' }
          it { is_expected.to eq(:current) }
        end
      end
    end

    context 'when VersionCompatibility is set' do
      before do
        instance.ios_mandatory_upgrade_version_threshold = 11
        instance.ios_optional_upgrade_version_threshold = 15
        instance.android_mandatory_upgrade_version_threshold = 20
        instance.android_optional_upgrade_version_threshold = 25
        instance.save
      end

      context 'ios' do
        let(:device_platform) { :ios }

        context '10' do
          let(:version) { '10' }
          it { is_expected.to eq(:update_required) }
        end

        context '11' do
          let(:version) { '11' }
          it { is_expected.to eq(:update_optional) }
        end

        context '15' do
          let(:version) { '15' }
          it { is_expected.to eq(:current) }
        end
      end

      context 'android' do
        let(:device_platform) { :android }

        context '19' do
          let(:version) { '19' }
          it { is_expected.to eq(:update_required) }
        end

        context '20' do
          let(:version) { '20' }
          it { is_expected.to eq(:update_optional) }
        end

        context '25' do
          let(:version) { '25' }
          it { is_expected.to eq(:current) }
        end
      end
    end
  end
end
