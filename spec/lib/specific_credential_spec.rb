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

  context '.instance' do
    subject { TestCredential.instance }

    before { instance.update_credentials(foo: 'value1') }

    context '#cred' do
      subject { instance.cred }
      it { is_expected.to eq('foo' => 'value1', 'bar' => nil) }
    end

    context '#foo' do
      subject { TestCredential.instance.foo }
      it { is_expected.to eq('value1') }
    end
  end

  context 'instance' do
    subject { instance }

    context '#cred_type' do
      subject { instance.cred_type }
      it { is_expected.to eq('test') }
    end

    specify do
      expect { subject.foo = 'value1' }.to change(subject, :cred)
        .from('foo' => nil, 'bar' => nil)
        .to('foo' => 'value1', 'bar' => nil)
    end

    context 'when foo is "value1"' do
      before do
        instance.foo = 'value1'
      end

      context '#foo' do
        subject { instance.foo }
        it { is_expected.to eq('value1') }
      end

      context '#cred' do
        subject { instance.cred }
        it { is_expected.to eq('foo' => 'value1', 'bar' => nil) }
      end

      context '#only_app_attributes' do
        subject { instance.only_app_attributes }
        it { is_expected.to eq(foo: 'value1', bar: nil) }
      end
    end

    context 'when record not found' do
      it { expect { subject }.to change(TestCredential, :count).by(1) }
    end

    context 'when record exists' do
      let(:cred) { { foo: 'value1', bar: 'value2' }.with_indifferent_access }
      let!(:record) { TestCredential.create(cred: cred) }
      it { is_expected.to eq(record) }

      context '#cred_type' do
        subject { instance.cred_type }
        it { is_expected.to eq('test') }
      end
    end
  end

  context '#update_credentials' do
    context 'when credentials is a Hash' do
      subject { instance.update_credentials(foo: 'us-west-1') }
      specify { expect { subject }.to change(instance, :foo).from(nil).to('us-west-1') }
    end

    context 'when credentials has not permitted attributes' do
      before { instance.update_credentials(foo: 'us-west-1', buzz: 'buzz') }
      subject { instance.cred }
      specify { is_expected.to eq('foo' => 'us-west-1', 'bar' => nil) }
    end

    context 'when credentials is not Hash' do
      subject { instance.update_credentials('foo') }
      specify { expect { subject }.to raise_error(TypeError) }
    end
  end
end
