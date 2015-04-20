require 'rails_helper'

RSpec.describe Kvstore, type: :model do
  describe 'columns' do
    it { is_expected.to have_db_column(:key1).of_type(:string) }
    it { is_expected.to have_db_column(:key2).of_type(:string) }
    it { is_expected.to have_db_column(:value).of_type(:string) }
  end
end
