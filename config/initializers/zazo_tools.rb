Zazo::Tool::Logger.configure do |config|
  logstash_url = Figaro.env.logstash_url
  if logstash_url && !(Rails.env.test? || Rails.env.development?)
    config.logstash_enabled = true
    config.logstash_host = logstash_url.split(':').first
    config.logstash_port = logstash_url.split(':').last
    config.logstash_username = Figaro.env.logstash_username
    config.logstash_password = Figaro.env.logstash_password
  end
  config.project_name = Settings.app_name_key
end

