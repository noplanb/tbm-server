namespace :eb do
  desc 'Deploy with EB CLI'
  task :deploy do
    run_locally do
      execute "eb deploy #{fetch :eb_env}"
    end
  end

  desc 'Fetch logs with EB CLI'
  task :logs do
    run_locally do
      execute "eb logs #{fetch :eb_env}"
    end
  end

  desc 'Open AWS console'
  task :console do
    run_locally do
      execute "eb console #{fetch :eb_env}"
    end
  end

  desc 'Open EB environment'
  task :open do
    run_locally do
      execute "eb open #{fetch :eb_env}"
    end
  end

  desc 'Login via SSH'
  task :ssh do
    run_locally do
      execute "eb ssh #{fetch :eb_env}"
    end
  end

  desc 'Set environment variables from Figaro'
  task :setenv do
    run_locally do
      execute "bundle exec figaro eb:set -e #{fetch :stage} --env #{fetch :eb_env}"
    end
  end
end
