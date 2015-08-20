RSpec.shared_context 'verification code on staging' do |method, status|
  context 'without forcing' do
    it 'receive :ok on staging environment' do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('staging'))
      is_expected.to eq(:ok)
    end
  end

  context 'with forcing' do
    let(:options) { { "force_#{method}" => 'true' } }

    it "receive :#{status} on staging environment" do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('staging'))
      is_expected.to eq(status)
    end
  end
end
