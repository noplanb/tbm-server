require 'rails_helper'

RSpec.describe S3Event do
  describe 'validations' do
    it { is_expected.to validate_presence_of :bucket_name }
    it { is_expected.to validate_presence_of :file_name }
    it { is_expected.to validate_presence_of :file_size }
  end

  describe 'mapping s3 event params' do
    let(:instance) { described_class.new s3_event_data }

    context 'with correct event data' do
      let(:s3_event_data) { json_fixture('s3_event')['Records'] }
      let(:expected_sample) { FactoryGirl.build :s3_event }

      it { expect(instance.bucket_name).to eq expected_sample.bucket_name }
      it { expect(instance.file_name).to   eq expected_sample.file_name }
      it { expect(instance).to be_valid  }
    end

    context 'with incorrect event data' do
      let(:s3_event_data) { json_fixture('s3_event_incorrect')['Records'] }

      it { expect(instance.bucket_name).to be nil  }
      it { expect(instance.file_name).to   be nil  }
      it { expect(instance).to be_invalid  }
    end
  end
end
