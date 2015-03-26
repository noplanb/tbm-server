namespace :deploy do
  desc 'Deploy with EB CLI'
  task :updating do
    invoke 'eb:deploy'
  end
end
