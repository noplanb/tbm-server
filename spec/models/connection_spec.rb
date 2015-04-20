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

  describe '.video_filename' do
    let!(:instance) { create(:connection, attributes) }
    subject { described_class.video_filename(creator, target, video_id) }
    it { is_expected.to eq('smRug5xj8J469qX5XvGk-IUed5vP9n4qzW6jY8wSu-8045bfdc02bcc27c87be785c5ffc3b62') }
  end

  describe '.kvstore_key' do
    let!(:instance) { create(:connection, attributes) }
    subject { described_class.kvstore_key(creator, target, instance) }
    it { is_expected.to eq('smRug5xj8J469qX5XvGk-IUed5vP9n4qzW6jY8wSu-19_21_XxInqAeDqnoS6BlP1M5S-VideoIdKVKey') }
  end

  describe '.add_remote_key' do
    let!(:instance) { create(:connection, attributes) }
    subject { described_class.add_remote_key(creator, target, video_id) }
    it { is_expected.to be_valid }
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
        before { described_class.add_remote_key(creator, target, video_id) }
        it { is_expected.to be_falsey }
      end
    end
  end
end