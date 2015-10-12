require 'rails_helper'

RSpec.describe S3Metadata do
  describe '.create_by_event' do
    let(:instance) { described_class.create_by_event s3_event }

    context 'with event is filled' do
      use_vcr_cassette 's3_get_metadata'
      let(:s3_event) { FactoryGirl.build :s3_event }

      it { expect(instance.client_version).to  eq 111 }
      it { expect(instance.client_platform).to eq 'android' }
      it { expect(instance.sender_mkey).to     eq 'ZcAK4dM9S4m0IFui6ok6' }
      it { expect(instance.receiver_mkey).to   eq 'lpb8DcispONUSfdMOT9g' }
      it { expect(instance.video_id).to        eq '1444235919617' }
    end

    context 'when event has incorrect data' do
      use_vcr_cassette 's3_get_metadata_legacy'
      let(:s3_event) { FactoryGirl.build :s3_event_legacy }

      it { expect(instance.client_version).to  eq 0 }
      it { expect(instance.client_platform).to be nil }
      it { expect(instance.sender_mkey).to     be nil }
      it { expect(instance.receiver_mkey).to   be nil }
      it { expect(instance.video_id).to        be nil }
    end

    context 'when event has incorrect data' do
      use_vcr_cassette 's3_get_metadata_incorrect'
      let(:s3_event) { FactoryGirl.build :s3_event, bucket_name: 'xxxxxxxxx', file_name: 'xxxxxxxxx' }

      it { expect(instance.client_version).to  eq 0 }
      it { expect(instance.client_platform).to be nil }
      it { expect(instance.sender_mkey).to     be nil }
      it { expect(instance.receiver_mkey).to   be nil }
      it { expect(instance.video_id).to        be nil }
    end
  end
end
