require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { build(:user) }

  describe 'columns' do
    it { is_expected.to have_db_column(:first_name).of_type(:string) }
    it { is_expected.to have_db_column(:last_name).of_type(:string) }
    it { is_expected.to have_db_column(:mobile_number).of_type(:string) }
    it { is_expected.to have_db_column(:emails).of_type(:text) }
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

  describe 'serialize' do
    it { is_expected.to serialize(:emails).as(Array) }
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
    let!(:user1) { create(:user, first_name: 'Alex', last_name: 'Appleseed') }
    let!(:user2) { create(:user, first_name: 'Sergii', last_name: 'Ulianytskyi') }
    let!(:user3) do
      create(:user, first_name: 'John', last_name: 'Smith',
                    mobile_number: '+380939523746')
    end

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

    context 'eliminate_invalid_emails' do
      let(:attributes) { attributes_for(:user, emails: ['valid@example.com', 'invalid@example', 'valid@example.com']) }
      let(:instance) { described_class.create(attributes) }

      context '#emails' do
        subject { instance.emails }
        it { is_expected.to eq(['valid@example.com']) }
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
      context 'with correct fresh code' do
        it 'passes with a fresh code' do
          code = user.get_verification_code
          expect(user.passes_verification(code)).to be true
        end

        it 'fails with a incorrect code' do
          expect(user.passes_verification('1234')).to be false
        end
      end

      context 'with backdoor' do
        let(:backdoor_code) { '4567' }
        before { ENV['verification_code_backdoor'] = backdoor_code }

        it 'passes with a correct backdoor code' do
          expect(user.passes_verification(backdoor_code)).to be true
        end

        it 'fails with a incorrect backdoor code' do
          expect(user.passes_verification('1234')).to be false
        end

        it 'fails on production' do
          allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
          expect(user.passes_verification(backdoor_code)).to be false
        end
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
      let!(:connection) { create(:established_connection, creator: user) }
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
      let!(:connection) { create(:established_connection, target: user) }
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
      let!(:connection1) { create(:established_connection, creator: user) }
      let!(:connection2) { create(:established_connection, target: user) }

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
    let!(:other) { create(:established_connection, creator: instance).target }
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
        let(:event_params) do
          { initiator: 'user',
            initiator_id: instance.mkey,
            data: options }
        end

        it_behaves_like 'event dispatchable', ['user', options[:to_state]]
      end
    end

    describe '#verify' do
      subject { instance.verify }
      before do
        allow(EventDispatcher.sqs_client).to receive(:send_message)
        instance.register!
      end
      let(:event_params) do
        { initiator: 'user',
          initiator_id: instance.mkey,
          data: { event: :verify,
                  from_state: :registered,
                  to_state: :verified } }
      end

      it_behaves_like 'event dispatchable', ['user', :verified]
    end

    describe '#pend' do
      subject { instance.pend }
      before do
        allow(EventDispatcher.sqs_client).to receive(:send_message)
        instance.register!
      end
      let(:event_params) do
        { initiator: 'user',
          initiator_id: instance.mkey,
          data: { event: :pend,
                  from_state: :registered,
                  to_state: :initialized } }
      end

      it_behaves_like 'event dispatchable', ['user', :initialized]
    end
  end

  describe '#received_videos' do
    let(:user) { create(:user) }
    subject { user.received_videos }

    let!(:friend_1) { create(:established_connection, creator: user).target }
    let!(:friend_2) { create(:established_connection, creator: user).target }
    let!(:friend_3) { create(:established_connection, creator: user).target }
    let!(:video_11) { Kvstore.add_id_key(friend_1, user, gen_video_id).key2 }
    let!(:video_12) { Kvstore.add_id_key(friend_1, user, gen_video_id).key2 }
    let!(:video_21) { Kvstore.add_id_key(friend_2, user, gen_video_id).key2 }
    let!(:video_22) { Kvstore.add_id_key(friend_2, user, gen_video_id).key2 }
    let!(:video_23) { Kvstore.add_id_key(friend_2, user, gen_video_id).key2 }

    it do
      expected = [
        { mkey: friend_1.mkey, video_ids: [video_11, video_12] },
        { mkey: friend_2.mkey, video_ids: [video_21, video_22, video_23] },
        { mkey: friend_3.mkey, video_ids: [] }
      ]
      is_expected.to include(*expected)
    end
  end

  context '#received_messages and #received_texts' do
    let(:user) { create(:user) }

    let!(:friend_1) { create(:established_connection, creator: user).target }
    let!(:friend_2) { create(:established_connection, creator: user).target }
    let!(:friend_3) { create(:established_connection, creator: user).target }
    let!(:friend_4) { create(:established_connection, creator: user).target }
    let!(:friend_5) { create(:established_connection, creator: user).target }

    let!(:message_11) { Kvstore.add_message_id_key('text', friend_1, user, gen_message_id, body: 'Message 11').key2 }
    let!(:message_12) { Kvstore.add_message_id_key('text', friend_1, user, gen_message_id, body: 'Message 12').key2 }
    let!(:message_21) { Kvstore.add_message_id_key('text', friend_2, user, gen_message_id, body: 'Message 21').key2 }
    let!(:message_22) { Kvstore.add_message_id_key('text', friend_2, user, gen_message_id, body: 'Message 22').key2 }
    let!(:message_23) { Kvstore.add_message_id_key('text', friend_2, user, gen_message_id, body: 'Message 23').key2 }
    let!(:video_41)   { Kvstore.add_id_key(friend_4, user, gen_message_id).key2 }
    let!(:video_42)   { Kvstore.add_id_key(friend_4, user, gen_message_id).key2 }

    describe '#received_messages' do
      subject { user.received_messages }

      it do
        expected = [
          {
            mkey: friend_1.mkey,
            messages: [
              { 'type' => 'text', 'messageId' => message_11, 'body' => 'Message 11' },
              { 'type' => 'text', 'messageId' => message_12, 'body' => 'Message 12' }
            ]
          }, {
            mkey: friend_2.mkey,
            messages: [
              { 'type' => 'text', 'messageId' => message_21, 'body' => 'Message 21' },
              { 'type' => 'text', 'messageId' => message_22, 'body' => 'Message 22' },
              { 'type' => 'text', 'messageId' => message_23, 'body' => 'Message 23' }
            ]
          }, {
            mkey: friend_3.mkey,
            messages: []
          }, {
            mkey: friend_4.mkey,
            messages: [
              { 'type' => 'video', 'messageId' => video_41 },
              { 'type' => 'video', 'messageId' => video_42 }
            ]
          }
        ]
        is_expected.to include(*expected)
      end
    end

    describe '#received_texts' do
      subject { user.received_texts }

      it do
        expected = [
          {
            mkey: friend_1.mkey,
            messages: [
              { 'type' => 'text', 'messageId' => message_11, 'body' => 'Message 11' },
              { 'type' => 'text', 'messageId' => message_12, 'body' => 'Message 12' }
            ]
          }, {
            mkey: friend_2.mkey,
            messages: [
              { 'type' => 'text', 'messageId' => message_21, 'body' => 'Message 21' },
              { 'type' => 'text', 'messageId' => message_22, 'body' => 'Message 22' },
              { 'type' => 'text', 'messageId' => message_23, 'body' => 'Message 23' }
            ]
          }, {
            mkey: friend_3.mkey,
            messages: []
          }, {
            mkey: friend_4.mkey,
            messages: []
          }
        ]
        is_expected.to include(*expected)
      end
    end
  end

  describe '#video_status' do
    let(:user) { create(:user) }
    subject { user.video_status }

    let!(:friend_1) { create(:established_connection, creator: user).target }
    let!(:friend_2) { create(:established_connection, creator: user).target }
    let!(:friend_3) { create(:established_connection, creator: user).target }

    let!(:video_11) { gen_video_id }
    let!(:video_12) { gen_video_id }
    let!(:video_21) { gen_video_id }
    let!(:video_22) { gen_video_id }
    let!(:video_23) { gen_video_id }

    let!(:video_101) { gen_video_id }
    let!(:video_102) { gen_video_id }
    let!(:video_201) { gen_video_id }
    let!(:video_202) { gen_video_id }
    let!(:video_203) { gen_video_id }

    let!(:kvstore_11) { Kvstore.add_status_key(user, friend_1, video_11, 'downloaded') }
    let!(:kvstore_12) { Kvstore.add_status_key(user, friend_1, video_12, 'downloaded') }
    let!(:kvstore_21) { Kvstore.add_status_key(user, friend_2, video_21, 'downloaded') }
    let!(:kvstore_22) { Kvstore.add_status_key(user, friend_2, video_22, 'viewed') }
    let!(:kvstore_23) { Kvstore.add_status_key(user, friend_2, video_23, 'viewed') }

    let!(:kvstore_101) { Kvstore.add_status_key(friend_1, user, video_101, 'viewed') }
    let!(:kvstore_102) { Kvstore.add_status_key(friend_1, user, video_102, 'downloaded') }
    let!(:kvstore_201) { Kvstore.add_status_key(friend_2, user, video_201, 'viewed') }
    let!(:kvstore_202) { Kvstore.add_status_key(friend_2, user, video_202, 'downloaded') }
    let!(:kvstore_203) { Kvstore.add_status_key(friend_2, user, video_203, 'downloaded') }

    it do
      expected = [
        { mkey: friend_1.mkey, video_id: video_12, status: 'downloaded' },
        { mkey: friend_2.mkey, video_id: video_23, status: 'viewed' },
        { mkey: friend_3.mkey, video_id: '', status: '' }
      ]
      is_expected.to include(*expected)
    end
  end

  describe '#message_status' do

  end

  describe '#add_emails' do
    let(:user) { create(:user, emails: ['test@example.com']) }
    subject { user.add_emails(emails) }
    context 'with string given' do
      let(:emails) { 'other@example.com' }
      it { is_expected.to eq(['test@example.com', 'other@example.com']) }
    end
    context 'with array given' do
      let(:emails) { ['other@example.com'] }
      it { is_expected.to eq(['test@example.com', 'other@example.com']) }
    end
  end
end
