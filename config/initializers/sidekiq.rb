redis_settings = {
  url: "redis://#{Figaro.env.redis_host}:#{Figaro.env.redis_port}",
  namespace: "#{Settings.app_name_key}-#{Rails.env}" }

Sidekiq.configure_server { |config| config.redis = redis_settings }
Sidekiq.configure_client { |config| config.redis = redis_settings }
