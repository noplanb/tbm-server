require 'rails_helper'

RSpec.describe HandleOutgoingVideo do
  describe '#do' do
    use_vcr_cassette 's3_get_metadata'

    let(:instance) { described_class.new s3_event_params }
    let(:s3_event_params) { json_fixture('s3_event')['Records'] }
    subject { instance.do }

    before do |example|
      allow_any_instance_of(Kvstore).to receive(:trigger_event).and_return true
      instance.do if example.metadata[:do_before]
    end

    it { expect(subject).to be true }
    it { expect { subject }.to change { Kvstore.count }.by 1 }
    it 'specific kvstore placed in database', :do_before do
      expect = %w(ZcAK4dM9S4m0IFui6ok6-lpb8DcispONUSfdMOT9g-da6f35c931ea53de0e24fb4c76beb5f3-VideoIdKVKey 1444235919617)
      expect(Kvstore.pluck(:key1, :key2).last).to eq expect
    end
  end
end
