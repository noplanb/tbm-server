require 'rails_helper'

RSpec.describe Connection, type: :model do
  let(:video_id) { '1426622544176' }
  let(:creator) { create(:user, mkey: 'smRug5xj8J469qX5XvGk') }
  let(:target) { create(:user, mkey: 'IUed5vP9n4qzW6jY8wSu') }
  let(:attributes) do
    { creator: creator,
      target: target,
      ckey: '19_21_XxInqAeDqnoS6BlP1M5S' }
  end

  describe 'columns' do
    it { is_expected.to have_db_column(:creator_id).of_type(:integer) }
    it { is_expected.to have_db_column(:target_id).of_type(:integer) }
    it { is_expected.to have_db_column(:status).of_type(:string) }
    it { is_expected.to have_db_column(:ckey).of_type(:string) }
  end

  describe 'validation' do
    it { is_expected.to validate_presence_of(:creator_id) }
    it { is_expected.to validate_presence_of(:target_id) }
    it { is_expected.to validate_presence_of(:status) }
  end

  describe '.find_or_create' do
    let(:creator) { create(:user) }
    let(:target) { create(:user) }
    subject { described_class.find_or_create(creator.id, target.id) }

    context 'when connection not exists' do
      it { is_expected.to be_established }
    end

    context 'when connection already exists' do
      context 'and voided' do
        let!(:connection) { create(:connection, creator: creator, target: target) }
        it { is_expected.to be_established }
      end

      context 'and established' do
        let!(:connection) { create(:established_connection, creator: creator, target: target) }
        it { is_expected.to be_established }
      end
    end
  end

  describe '#active?' do
    let(:instance) { create(:connection, attributes) }
    subject { instance.active? }

    context 'when connection is not established' do
      it { is_expected.to be_falsey }
    end

    context 'when connection is established' do
      let!(:instance) { create(:connection, attributes.merge(status: :established)) }
      context 'when no KV store records' do
        it { is_expected.to be_falsey }
      end

      context 'when only one direction videos in KV store' do
        before { Kvstore.add_id_key(creator, target, video_id) }
        it { is_expected.to be_falsey }
      end
    end
  end

  describe 'states' do
    let(:instance) { create(:connection) }
    describe '#establish' do
      subject { instance.establish }
      let(:event_params) do
         { initiator: 'connection',
           initiator_id: instance.ckey,
           data: { event: :establish,
                   from_state: :voided,
                   to_state: :established } }
      end

      it_behaves_like 'event dispatchable', 'connection:established'
    end

    describe '#void' do
      subject { instance.void }
      before do
        allow(EventDispatcher.sqs_client).to receive(:send_message)
        instance.establish!
      end
      let(:event_params) do
         { initiator: 'connection',
           initiator_id: instance.ckey,
           data: { event: :void,
                   from_state: :established,
                   to_state: :voided } }
      end

      it_behaves_like 'event dispatchable', 'connection:voided'
    end
  end
end
