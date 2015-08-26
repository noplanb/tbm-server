namespace :aglio do
  desc 'Generate index.html from apiary.apib'
  task :generate, [:theme_variables] => :environment do |_task, args|
    theme_variables = args[:theme_variables] || 'default'
    path = Rails.root.join('doc/api.html')
    system "aglio --theme-full-width --theme-variables=#{theme_variables} -i apiary.apib -o #{path}"
  end
end
