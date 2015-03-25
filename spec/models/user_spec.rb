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

  describe 'after_create' do
    let(:user) { create(:unknown_user) }

    context '#status' do
      subject { user.status }
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
end
