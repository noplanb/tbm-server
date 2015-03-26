# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'zazo'
set :repo_url, 'https://github.com/noplanb/tbm-server'

set :current_revision, `git rev-parse HEAD`.chomp
set :commit_url, -> { "#{repo_url}/commit/#{fetch :current_revision}" }

# Default branch is :master
set :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :slack_webhook, 'https://hooks.slack.com/services/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'
set :slack_channel, '#dev'
set :slack_username, 'Elastic Beanstalk'
set :slack_icon_url, nil
set :slack_icon_emoji, nil
set :slack_msg_starting, -> { "#{local_user} has started deploying branch \`#{fetch :branch}\` (<#{fetch :commit_url}|#{fetch(:current_revision)[0..8]}>) of #{fetch :application} to *#{fetch :stage, 'production'}* [#{fetch :eb_env}]" }
set :slack_msg_finished, -> { "#{local_user} has finished deploying branch \`#{fetch :branch}\` (<#{fetch :commit_url}|#{fetch(:current_revision)[0..8]}>) of #{fetch :application} to *#{fetch :stage, 'production'}* [#{fetch :eb_env}]" }
set :slack_msg_failed,   -> { "#{local_user} failed to deploy branch \`#{fetch :branch}\` (<#{fetch :commit_url}|#{fetch(:current_revision)[0..8]}>) of #{fetch :application} to *#{fetch :stage, 'production'}* [#{fetch :eb_env}]" }

after 'deploy:finished', 'airbrake:deploy'
