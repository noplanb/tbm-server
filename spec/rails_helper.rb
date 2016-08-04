ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'

reports_dir = ENV['WERCKER_REPORT_ARTIFACTS_DIR'] || File.expand_path('../../tmp', __FILE__)

if ENV.key?('coverage') || ENV.key?('CI')
  require 'simplecov'
  SimpleCov.coverage_dir File.join(reports_dir, 'coverage')
  SimpleCov.start :rails
end

require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!

  if ENV.key?('CI')
    config.add_formatter :html, File.join(reports_dir, 'rspec', 'rspec.html')
  end
end

RSpec::Sidekiq.configure do |config|
  config.warn_when_jobs_not_processed_by_sidekiq = false
end
