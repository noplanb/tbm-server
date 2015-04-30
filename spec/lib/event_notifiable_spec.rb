require 'rails_helper'

class TestClass
  include AASM
  include EventNotifiable

  aasm do
    state :pending, initial: true
    state :active

    event :activate do
      transitions from: :pending, to: :active
    end
  end

  def id
    'test_id'
  end
end

RSpec.describe EventNotifiable do
  let(:instance) { TestClass.new }
  let(:data) do
    { event: :activate,
      from_state: :pending,
      to_state: :active }
  end
  let(:params) do
     { initiator: 'test_class',
       initiator_id: instance.event_id,
       data: data }
  end

  describe '#notify_state_changed' do
    before { instance.activate }
    subject { instance.notify_state_changed }
    it_behaves_like 'event dispatchable', 'test_class:active'
  end
end
