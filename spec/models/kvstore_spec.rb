require 'rails_helper'

RSpec.describe Kvstore, type: :model do
  let(:video_id) { '1426622544176' }
  let(:sender) { create(:user, mkey: 'smRug5xj8J469qX5XvGk') }
  let(:receiver) { create(:user, mkey: 'IUed5vP9n4qzW6jY8wSu') }
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

  describe '.video_filename' do
    let!(:connection) { create(:connection, connection_attributes) }
    subject { described_class.video_filename(sender, receiver, video_id) }
    it { is_expected.to eq('smRug5xj8J469qX5XvGk-IUed5vP9n4qzW6jY8wSu-8045bfdc02bcc27c87be785c5ffc3b62') }
  end

  describe '.generate_key' do
    let!(:connection) { create(:connection, connection_attributes) }
    subject { described_class.generate_key(sender, receiver, connection) }
    it { is_expected.to eq('smRug5xj8J469qX5XvGk-IUed5vP9n4qzW6jY8wSu-19_21_XxInqAeDqnoS6BlP1M5S-VideoIdKVKey') }
  end

  describe '.add_remote_key' do
    let!(:connection) { create(:connection, connection_attributes) }
    subject { described_class.add_remote_key(sender, receiver, video_id) }
    it { is_expected.to be_valid }
  end

end
