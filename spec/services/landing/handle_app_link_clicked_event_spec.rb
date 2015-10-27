require 'rails_helper'

RSpec.describe Landing::HandleAppLinkClickedEvent do
  let(:instance) { described_class.new user_agent, additions }
  let(:user_agent) { 'Mozilla/5.0 (Linux; Android 4.4.2; Nexus 4 Build/KOT49H) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.114 Mobile Safari/537.36' }

  describe '#do' do
    subject { instance.do }

    context 'with correct connection_id' do
      let(:additions) { { connection: FactoryGirl.create(:connection) } }
      it do
        expect(EventDispatcher).to receive(:emit).with %w(user app_link_clicked), instance_of(Hash)
        subject
      end
    end

    context 'with incorrect connection' do
      let(:additions) { { connection: nil } }
      it do
        expect(EventDispatcher).to receive(:emit).with %w(user app_link_clicked), instance_of(Hash)
        subject
      end
    end
  end

  describe '#get_platform_and_path' do
    subject { instance.get_platform_and_path }
    let(:additions) { {} }

    context 'when iphone device' do
      let(:user_agent) { 'Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25' }
      it { is_expected.to eq [:ios, Settings.iphone_store_url] }
    end

    context 'when android device' do
      let(:user_agent) { 'Mozilla/5.0 (Linux; Android 4.4.2; Nexus 4 Build/KOT49H) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.114 Mobile Safari/537.36' }
      it { is_expected.to eq [:android, Settings.android_store_url] }
    end

    context 'when unknown device' do
      let(:user_agent) { 'Mozilla/5.0 (compatible; MSIE 10.0; Windows Phone 8.0; Trident/6.0; IEMobile/10.0; ARM; Touch; NOKIA; Lumia 920)' }
      it { is_expected.to eq [:mobile_device, '/'] }
    end
  end

  describe '#sqs_event_data' do
    subject { instance.send :sqs_event_data }

    context 'when additions contains inviter' do
      let(:additions) { { inviter: create(:user) } }
      it do
        expect = {
          link_key: 'l',
          inviter_id: additions[:inviter].id,
          inviter_mkey: additions[:inviter].mkey,
        }
        is_expected.to eq expect
      end
    end

    context 'when additions contains connection' do
      let(:additions) { { connection: create(:connection) } }
      it do
        expect = {
          link_key: 'c',
          connection_id: additions[:connection].id,
          connection_creator_mkey: additions[:connection].creator.mkey,
          connection_target_mkey: additions[:connection].target.mkey,
        }
        is_expected.to eq expect
      end
    end

    context 'without additions' do
      let(:additions) { {} }
      it { is_expected.to eq({}) }
    end
  end
end
