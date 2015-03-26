namespace :airbrake do
  desc "Notify Airbrake of the deployment"
  task :deploy do
    run_locally do
      # Compose the command notify_command
      airbrake_env = fetch(:airbrake_env, fetch(:rails_env, fetch(:stage)))
      notify_command = "airbrake:deploy"
      notify_command << " TO=#{airbrake_env}"
      notify_command << " REVISION=#{fetch(:current_revision)} REPO=#{fetch(:repo_url)}"
      notify_command << " USER=#{local_user.strip.shellescape}"
      notify_command << " API_KEY=#{ENV['API_KEY']}" if ENV['API_KEY']

      info "Notifying Airbrake of Deploy (#{notify_command})"
      rake notify_command
      info "Airbrake Notification Complete."
    end
  end
end
