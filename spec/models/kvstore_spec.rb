require 'rails_helper'

RSpec.describe Kvstore, type: :model do
  describe 'columns' do
    it { is_expected.to have_db_column(:key1).of_type(:string) }
    it { is_expected.to have_db_column(:key2).of_type(:string) }
    it { is_expected.to have_db_column(:value).of_type(:string) }
  end

  describe '.items_for', pending: 'TODO: implement' do
    let(:video_id) { (Time.now.to_f * 1000).to_i.to_s }
    let(:connection) { create(:connection) }
    let!(:instance1) { connection.add_remote_key(video_id) }
    let!(:instance2) { create(:kvstore) }

    subject { descibed_class.items_for(connection.creator, connection.target) }

    it { is_expected.to eq[instance1] }
  end
end
