redis_settings = {
  url: "redis://#{Figaro.env.redis_host}:#{Figaro.env.redis_port}",
  namespace: Settings.app_name_key }

Sidekiq.configure_server do |config|
  config.redis = redis_settings
end

Sidekiq.configure_client do |config|
  config.redis = redis_settings
end
