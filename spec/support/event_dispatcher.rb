RSpec.configure do |config|
  config.around do |example|
    EventDispatcher.disable_send_message!
    example.run
    EventDispatcher.enable_send_message!
  end

  config.before(event_dispatcher: true) do
    EventDispatcher.enable_send_message!
  end

  config.before(event_dispatcher: false) do
    EventDispatcher.disable_send_message!
  end
end
