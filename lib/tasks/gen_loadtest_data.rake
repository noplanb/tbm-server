namespace :gen_loadtest_data do
  task :push_user do
    file = "pu.csv"
    puts "Generating load test data for push_user table"
    
    FileUtils.rm(file) if File.exist?(file)
    File.open(file, 'a') do |f|
      (1..675000).each do |i|
        f.write %{\\N,"this_is_a_relatively_long_mkey_that_is_used_for_load_testing_#{i}","this_is_a_relatively_long_push_token_that_is_used_for_load_testing_#{i}","ios","prod",\\N,\\N\n}
        puts i if i%100000 == 0
      end
    end
    puts "Generated file: #{file}"
  end
  
end
