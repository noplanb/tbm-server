require 'rails_helper'

RSpec.shared_examples 'event dispatchable' do |event|
  specify do
    allow(EventDispatcher.sqs_client).to receive(:send_message)
    expect(EventDispatcher).to receive(:emit).with(event, params)
    subject
  end

  specify do
    expect(EventDispatcher.sqs_client).to receive(:send_message)
    subject
  end
end
