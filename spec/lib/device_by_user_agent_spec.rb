require 'rails_helper'

RSpec.describe DeviceByUserAgent do
  let(:instance) { described_class.new user_agent }

  let(:chrome)   { 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.101 Safari/537.36' }
  let(:iphone)   { 'Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25' }
  let(:ipad)     { 'Mozilla/5.0 (iPad; CPU OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25' }
  let(:android)  { 'Mozilla/5.0 (Linux; Android 4.4.2; Nexus 4 Build/KOT49H) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.114 Mobile Safari/537.36' }
  let(:winphone) { 'Mozilla/5.0 (compatible; MSIE 10.0; Windows Phone 8.0; Trident/6.0; IEMobile/10.0; ARM; Touch; NOKIA; Lumia 920)' }

  describe '#mobile_device?' do
    subject { instance.mobile_device? }

    context 'when chrome'   do let(:user_agent) { chrome }; it { is_expected.to be false } end
    context 'when iphone'   do let(:user_agent) { iphone }; it { is_expected.to be true } end
    context 'when ipad'     do let(:user_agent) { ipad }; it { is_expected.to be true } end
    context 'when android'  do let(:user_agent) { android }; it { is_expected.to be true } end
    context 'when winphone' do let(:user_agent) { winphone }; it { is_expected.to be true } end
  end

  describe '#android?' do
    subject { instance.android? }

    context 'when chrome'   do let(:user_agent) { chrome }; it { is_expected.to be false } end
    context 'when iphone'   do let(:user_agent) { iphone }; it { is_expected.to be false } end
    context 'when ipad'     do let(:user_agent) { ipad }; it { is_expected.to be false } end
    context 'when android'  do let(:user_agent) { android }; it { is_expected.to be true } end
    context 'when winphone' do let(:user_agent) { winphone }; it { is_expected.to be false } end
  end

  describe '#ios?' do
    subject { instance.ios? }

    context 'when chrome'   do let(:user_agent) { chrome }; it { is_expected.to be false } end
    context 'when iphone'   do let(:user_agent) { iphone }; it { is_expected.to be true } end
    context 'when ipad'     do let(:user_agent) { ipad }; it { is_expected.to be true } end
    context 'when android'  do let(:user_agent) { android }; it { is_expected.to be false } end
    context 'when winphone' do let(:user_agent) { winphone }; it { is_expected.to be false } end
  end

  describe '#windows_phone?' do
    subject { instance.windows_phone? }

    context 'when chrome'   do let(:user_agent) { chrome }; it { is_expected.to be false } end
    context 'when iphone'   do let(:user_agent) { iphone }; it { is_expected.to be false } end
    context 'when ipad'     do let(:user_agent) { ipad }; it { is_expected.to be false } end
    context 'when android'  do let(:user_agent) { android }; it { is_expected.to be false } end
    context 'when winphone' do let(:user_agent) { winphone }; it { is_expected.to be true } end
  end
end
