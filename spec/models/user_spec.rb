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

  describe '.search', pending: 'Implement' do
    subject { described_class.search(query) }
    let!(:user1) { create(:user, first_name: 'Alex') }
    let!(:user2) { create(:user, last_name: 'Ulinaytskyi') }
    let!(:user3) { create(:user, mobile_number: '+380939523746') }

    context 'Alex' do
      let(:query) { 'Alex' }
      it { is_expected.to eq([user1]) }
    end

    context 'Ulinaytskyi' do
      let(:query) { 'Ulinaytskyi' }
      it { is_expected.to eq([user2]) }
    end

    context '+380939523746' do
      let(:query) { '+380939523746' }
      it { is_expected.to eq([user3]) }
    end
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
        expect(v1).not_to  eq v2
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

end
