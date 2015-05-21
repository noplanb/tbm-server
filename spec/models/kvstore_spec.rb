require 'rails_helper'

RSpec.describe Kvstore, type: :model do
  let(:video_id) { '1426622544176' }
  let(:sender_mkey) { 'smRug5xj8J469qX5XvGk' }
  let(:receiver_mkey) { 'IUed5vP9n4qzW6jY8wSu' }
  let(:sender) { create(:user, mkey: sender_mkey) }
  let(:receiver) { create(:user, mkey: receiver_mkey) }
  let(:connection_attributes) do
    { creator: sender,
      target: receiver,
      ckey: '19_21_XxInqAeDqnoS6BlP1M5S' }
  end

  describe 'columns' do
    it { is_expected.to have_db_column(:key1).of_type(:string) }
    it { is_expected.to have_db_column(:key2).of_type(:string) }
    it { is_expected.to have_db_column(:value).of_type(:string) }
  end

  describe '.digest' do
    subject { described_class.digest('foo') }
    it { is_expected.to eq('acbd18db4cc2f85cedef654fccc4a4d8') }
  end

  describe '.video_filename' do
    subject { described_class.video_filename(sender, receiver, video_id) }

    context 'when connection exists' do
      let!(:connection) { create(:established_connection, connection_attributes) }
      it { is_expected.to eq('smRug5xj8J469qX5XvGk-IUed5vP9n4qzW6jY8wSu-8045bfdc02bcc27c87be785c5ffc3b62') }

      context 'when sender and receiver is mkeys' do
        subject { described_class.video_filename(sender_mkey, receiver_mkey, video_id) }
        it { is_expected.to eq('smRug5xj8J469qX5XvGk-IUed5vP9n4qzW6jY8wSu-8045bfdc02bcc27c87be785c5ffc3b62') }
      end
    end

    context 'when connection not exists' do
      specify { expect { subject }.to raise_error("No connection found between #{sender.name} and #{receiver.name}")}
    end

    context 'when user not exists' do
      subject { described_class.video_filename(sender_mkey, receiver_mkey, video_id) }
      specify { expect { subject }.to raise_error(ActiveRecord::RecordNotFound) }
    end
  end

  describe '.generate_id_key' do
    let!(:connection) { create(:established_connection, connection_attributes) }
    subject { described_class.generate_id_key(sender, receiver, connection) }
    it { is_expected.to eq('smRug5xj8J469qX5XvGk-IUed5vP9n4qzW6jY8wSu-19_21_XxInqAeDqnoS6BlP1M5S-VideoIdKVKey') }
  end

  describe '.generate_status_key' do
    let!(:connection) { create(:established_connection, connection_attributes) }
    subject { described_class.generate_status_key(sender, receiver, connection) }
    it { is_expected.to eq('smRug5xj8J469qX5XvGk-IUed5vP9n4qzW6jY8wSu-d8b49aa0143e0cc66ee154fab6538083-VideoStatusKVKey') }
  end

  describe '.add_id_key' do
    let!(:connection) { create(:established_connection, connection_attributes) }
    subject { described_class.add_id_key(sender, receiver, video_id) }
    it { is_expected.to be_valid }
  end

  describe '.add_status_key' do
    let!(:connection) { create(:established_connection, connection_attributes) }
    subject { described_class.add_status_key(sender, receiver, video_id, :downloaded) }
    it { is_expected.to be_valid }
  end

  describe '.create_or_update' do
    subject { described_class.create_or_update(params) }
    let!(:connection) { create(:established_connection, connection_attributes) }
    let(:video_filename) { described_class.video_filename(sender_mkey, receiver_mkey, video_id) }

    context 'video id' do
      let(:params) do
        { key1: described_class.generate_id_key(sender, receiver, connection),
          key2: video_id, value: { 'videoId' => video_id }.to_json }
      end

      specify do
        expect { subject }.to change { described_class.count }.by(1)
      end

      context 'event notification' do
        let(:event_params) do
          { initiator: 'user',
            initiator_id: sender.mkey,
            target: 'video',
            target_id: video_filename,
            data: {
              sender_id: sender.mkey,
              receiver_id: receiver.mkey,
              video_filename: video_filename,
              video_id: video_id
            },
            raw_params: params.stringify_keys }
        end

        it_behaves_like 'event dispatchable', %w(video kvstore received)
      end
    end

    context 'video status' do
      let(:params) do
        { key1: described_class.generate_status_key(sender, receiver, connection),
          key2: nil, value: { 'status' => 'downloaded', 'videoId' => video_id }.to_json }
      end

      specify do
        expect { subject }.to change { described_class.count }.by(1)
      end

      context 'event notification' do
        let(:event_params) do
          { initiator: 'user',
            initiator_id: sender.mkey,
            target: 'video',
            target_id: video_filename,
            data: {
              sender_id: sender.mkey,
              receiver_id: receiver.mkey,
              video_filename: video_filename,
              video_id: video_id
            },
            raw_params: params.stringify_keys }
        end

        it_behaves_like 'event dispatchable', %w(video kvstore downloaded)
      end
    end
  end

end
