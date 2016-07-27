RSpec.configure do |config|
  config.around(event_dispatcher: false) do |example|
    Zazo::Tool::EventDispatcher.with_state(false) { example.run }
  end

  config.around(event_dispatcher: true) do |example|
    Zazo::Tool::EventDispatcher.with_state(true) { example.run }
  end
end
