require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { build(:user) }

  describe 'columns' do
    it { is_expected.to have_db_column(:first_name).of_type(:string) }
    it { is_expected.to have_db_column(:last_name).of_type(:string) }
    it { is_expected.to have_db_column(:mobile_number).of_type(:string) }
    it { is_expected.to have_db_column(:email).of_type(:string) }
    it { is_expected.to have_db_column(:user_name).of_type(:string) }
    it { is_expected.to have_db_column(:device_platform).of_type(:string) }
    it { is_expected.to have_db_column(:auth).of_type(:string) }
    it { is_expected.to have_db_column(:mkey).of_type(:string) }
    it { is_expected.to have_db_column(:verification_code).of_type(:string) }
    it { is_expected.to have_db_column(:verification_date_time).of_type(:datetime) }
    it { is_expected.to have_db_column(:status).of_type(:string) }
  end

  describe 'validations' do
    it { is_expected.to validate_uniqueness_of(:mobile_number) }
  end

  describe 'indexes' do
    it { is_expected.to have_db_index(:mkey) }
    it { is_expected.to have_db_index(:mobile_number) }
  end

  describe '.find_by_raw_mobile_number' do
    let(:mobile_number) { '+1 650-111-0000' }
    subject { described_class.find_by_raw_mobile_number(mobile_number) }

    context 'when record not exists' do
      it { is_expected.to be_nil }
    end

    context 'when record already exists' do
      let!(:user) { create(:user, mobile_number: mobile_number) }
      it { is_expected.to eq(user) }
    end
  end

  describe '.search' do
    subject { described_class.search(query) }
    let!(:user1) { create(:user, first_name: 'Alex') }
    let!(:user2) { create(:user, last_name: 'Ulianytskyi') }
    let!(:user3) { create(:user, mobile_number: '+380939523746') }

    context 'Alex' do
      let(:query) { 'Alex' }
      it { is_expected.to eq([user1]) }
    end

    context 'alex' do
      let(:query) { 'alex' }
      it { is_expected.to eq([user1]) }
    end

    context 'Ulian' do
      let(:query) { 'Ulian' }
      it { is_expected.to eq([user2]) }
    end

    context 'ulian' do
      let(:query) { 'ulian' }
      it { is_expected.to eq([user2]) }
    end

    context '+380939523746' do
      let(:query) { '+380939523746' }
      it { is_expected.to eq([user3]) }
    end

    context 'empty string' do
      let(:query) { '' }
      it { is_expected.to eq([user1, user2, user3]) }
    end

    context 'nil' do
      let(:query) {}
      it { is_expected.to eq([user1, user2, user3]) }
    end
  end

  describe 'before_save' do
    let(:user) { create(:unknown_user) }

    context '#status' do
      subject { user.status }
      it { is_expected.to eq('initialized') }
    end

    context '#aasm.current_state' do
      subject { user.aasm.current_state }
      it { is_expected.to eq(:initialized) }
    end

    context '#mkey' do
      subject { user.mkey }
      it { is_expected.to be_present }
    end

    context '#auth' do
      subject { user.auth }
      it { is_expected.to be_present }
    end

    context '#first_name' do
      subject { user.first_name }
      it { is_expected.to eq('') }
    end

    context '#last_name' do
      subject { user.last_name }
      it { is_expected.to eq('') }
    end

    context 'strips emoji' do
      let(:attributes) { { first_name: 'Justin Michael 🐔💚', last_name: 'Justin Michael 🐔💚', device_platform: :ios } }
      let(:instance) { described_class.create(attributes) }

      context 'first_name' do
        subject { instance.first_name }
        it { is_expected.to eq('Justin Michael') }
      end

      context 'last_name' do
        subject { instance.last_name }
        it { is_expected.to eq('Justin Michael') }
      end
    end
  end

  describe '#name' do
    let(:user) { build(:user, first_name: 'John', last_name: 'Smith') }
    subject { user.name }
    it { is_expected.to eq('John Smith') }
  end

  describe '#info' do
    let(:user) { create(:user) }
    subject { user.info }
    it { is_expected.to eq("#{user.name}[#{user.id}]") }
  end

  describe '#mobile_number=' do
    let(:mobile_number) { '983.703.3249' }
    it 'normalizes mobile number' do
      user.mobile_number = mobile_number
      expect(user.mobile_number).to eq('+19837033249')
    end
  end

  describe 'Verification Code Methods' do
    let(:user) { create(:user) }

    describe '#verification_code_will_expire_in?' do
      it 'is true when verification_code is blank' do
        user.verification_date_time = 24.hours.from_now
        expect(user.verification_code_will_expire_in?(0))
      end

      it 'is true when verification_date_time blank' do
        user.verification_code = '1234'
        expect(user.verification_code_will_expire_in?(0))
      end

      it 'is true if verification will have expired' do
        user.verification_code = '1234'
        user.verification_date_time = 10.minutes.from_now
        expect(user.verification_code_will_expire_in?(11.minutes))
      end

      it 'is false if verification will have expired' do
        user.verification_code = '1234'
        user.verification_date_time = 10.minutes.from_now
        expect(!user.verification_code_will_expire_in?(9.minutes))
      end
    end

    describe '#reset_verification_code' do
      it 'resets if code is blank' do
        expect(user.verification_code_expired?)
        user.reset_verification_code
        expect(!user.verification_code_expired?)
      end

      it 'resets if code will expire less than 2 minutes' do
        expect(user.verification_code_expired?)
        user.set_verification_code
        user.verification_date_time = 2.minutes.from_now
        expect(user.verification_code_will_expire_in?(2))
        user.reset_verification_code
        expect(!user.verification_code_will_expire_in?(Settings.verification_code_lifetime_minutes - 1))
      end
    end

    describe '#get_verification_code' do
      it 'gets a fresh code if blank' do
        expect(user.get_verification_code)
      end

      it 'resets verification code if code will expire in less than 2 minutes' do
        user.set_verification_code
        user.verification_date_time = 2.minutes.from_now
        v1 = user.verification_code
        expect(v1)
        v2 = user.get_verification_code
        expect(v2)
        expect(v1).not_to eq v2
      end
    end

    describe '#passes_verification(code)' do
      it 'passes with a fresh code' do
        code = user.get_verification_code
        expect(user.passes_verification(code))
      end
    end

    describe '#set_verification_code' do
      it 'sets code of length Settings.verification_code_length' do
        user.set_verification_code
        expect(user.verification_code.length).to eq(Settings.verification_code_length)
      end

      it 'sets verification_date_time to Settings.verification_code_lifetime_minutes from now' do
        user.set_verification_code
        expect((user.verification_date_time - Time.now - Settings.verification_code_lifetime_minutes.minutes).abs).to be < 1
      end
    end

    describe '#random_number(n)' do
      it 'is expected to have length n' do
        expect(user.random_number(10).size).to eq(10)
      end

      it 'is expected to be composed of digits' do
        expect(user.random_number(10).match(/^\d+$/))
      end
    end
  end

  describe '#active_connections' do
    let(:video_id) { '1426622544176' }
    let(:user) { create(:user) }
    subject { user.active_connections }

    context 'when is no connections for user' do
      it { is_expected.to eq([]) }
    end

    context 'when 1 connection as a creator' do
      let!(:connection) { create(:connection, :established, creator: user) }
      context 'and 1 ongoing video' do
        before { Kvstore.add_id_key(connection.creator, connection.target, video_id) }
        it { is_expected.to eq([]) }
      end
      context 'and 1 incoming video' do
        before { Kvstore.add_id_key(connection.target, connection.creator, video_id) }
        it { is_expected.to eq([]) }
      end
      context 'and ongoing & incoming videos' do
        before { Kvstore.add_id_key(connection.creator, connection.target, video_id) }
        before { Kvstore.add_id_key(connection.target, connection.creator, video_id) }
        it { is_expected.to eq([connection]) }
      end
    end

    context 'when 1 connection as a target' do
      let!(:connection) { create(:connection, :established, target: user) }
      context 'and 1 ongoing video' do
        before { Kvstore.add_id_key(connection.creator, connection.target, video_id) }
        it { is_expected.to eq([]) }
      end
      context 'and 1 incoming video' do
        before { Kvstore.add_id_key(connection.target, connection.creator, video_id) }
        it { is_expected.to eq([]) }
      end
      context 'and ongoing & incoming videos' do
        before { Kvstore.add_id_key(connection.creator, connection.target, video_id) }
        before { Kvstore.add_id_key(connection.target, connection.creator, video_id) }
        it { is_expected.to eq([connection]) }
      end
    end

    context 'when 1 connection as a creator & 1 as a target' do
      let!(:connection1) { create(:connection, :established, creator: user) }
      let!(:connection2) { create(:connection, :established, target: user) }

      context 'for first connection' do
        context 'and 1 ongoing video' do
          before { Kvstore.add_id_key(connection1.creator, connection1.target, video_id) }
          it { is_expected.to eq([]) }
        end
        context 'and 1 incoming video' do
          before { Kvstore.add_id_key(connection1.target, connection1.creator, video_id) }
          it { is_expected.to eq([]) }
        end
        context 'and ongoing & incoming videos' do
          before { Kvstore.add_id_key(connection1.creator, connection1.target, video_id) }
          before { Kvstore.add_id_key(connection1.target, connection1.creator, video_id) }
          it { is_expected.to eq([connection1]) }
        end
        context 'and ongoing status & incoming videos' do
          before { Kvstore.add_status_key(connection1.creator, connection1.target, video_id, :downloaded) }
          before { Kvstore.add_id_key(connection1.target, connection1.creator, video_id) }
          it { is_expected.to eq([connection1]) }
        end
      end

      context 'for both connections' do
        context 'and ongoing & incoming videos' do
          before { Kvstore.add_id_key(connection1.creator, connection1.target, video_id) }
          before { Kvstore.add_id_key(connection2.creator, connection2.target, video_id) }
          before { Kvstore.add_id_key(connection1.target, connection1.creator, video_id) }
          before { Kvstore.add_id_key(connection2.target, connection2.creator, video_id) }
          it { is_expected.to eq([connection1, connection2]) }
        end
      end
    end
  end

  describe '#connected_user_ids' do
    let(:instance) { create(:user) }
    let!(:other) { create(:connection, :established, creator: instance).target }
    subject { instance.connected_user_ids }

    it { is_expected.to eq([other.id]) }
  end

  describe 'state chanages' do
    let!(:instance) { create(:user) }

    [
      { event: :invite, from_state: :initialized, to_state: :invited },
      { event: :register, from_state: :initialized, to_state: :registered },
      { event: :fail_to_register, from_state: :initialized, to_state: :failed_to_register }
    ].each do |options|
      describe "##{options[:event]}" do
        subject { instance.send options[:event] }
        let(:params) do
           { initiator: :user,
             initiator_id: instance.mkey,
             data: options }
        end

        it_behaves_like 'event dispatchable', "user:#{options[:to_state]}"
      end
    end

    describe '#verify' do
      subject { instance.verify }
      before do
        allow(EventDispatcher.sqs_client).to receive(:send_message)
        instance.register!
      end
      let(:params) do
         { initiator: :user,
           initiator_id: instance.mkey,
           data: { event: :verify,
                   from_state: :registered,
                   to_state: :verified } }
      end

      it_behaves_like 'event dispatchable', 'user:verified'
    end

    describe '#pend' do
      subject { instance.pend }
      before do
        allow(EventDispatcher.sqs_client).to receive(:send_message)
        instance.register!
      end
      let(:params) do
         { initiator: :user,
           initiator_id: instance.mkey,
           data: { event: :pend,
                   from_state: :registered,
                   to_state: :initialized } }
      end

      it_behaves_like 'event dispatchable', 'user:initialized'
    end
  end
end
