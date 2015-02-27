require 'rails_helper'

# Model to test SpecificCredential behaviour
class TestCredential < Credential
  include SpecificCredential
  define_attributes :foo, :bar
end

RSpec.describe SpecificCredential, type: :model do
  let(:model) { TestCredential }
  let(:instance) { model.instance }

  subject { model }
  it { is_expected.to respond_to(:credential_attributes) }

  context '.credential_type' do
    subject { model.credential_type }
    it { is_expected.to eq('test') }
  end

  context 'instance' do
    context '#cred_type' do
      subject { instance.cred_type }
      it { is_expected.to eq('test') }
    end

    context 'when foo is "value1"' do
      before do
        instance.foo = 'value1'
        instance.save
      end

      context '#foo' do
        subject { instance.reload.foo }
        it { is_expected.to eq('value1') }
      end

      context '#cred' do
        subject { instance.reload.cred }
        it { is_expected.to eq({ 'foo' => 'value1', 'bar' => nil }.to_json) }
      end

      context '#only_app_attributes' do
        subject { instance.reload.only_app_attributes }
        it { is_expected.to eq(foo: 'value1', bar: nil) }
      end
    end
  end
end
