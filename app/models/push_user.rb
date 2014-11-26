class PushUser < ActiveRecord::Base
  include EnumHandler
  
  define_enum :device_platform, [:ios,:android], :primary => true
  define_enum :device_build, [:dev,:prod]
  
  def self.create_or_update(params)
    params = params.slice(:mkey, :push_token, :device_platform, :device_build)
    if push_user = PushUser.find_by_mkey(params[:mkey])
      push_user.update_attributes(params)
    else
      PushUser.create(params)
    end
  end
  
  
  # ================
  # = Load Testing =
  # ================
  def self.load_test_populate(first, last)
    (first.to_i..last.to_i).each do |n|
      params = {mkey:"this_is_a_relatively_long_mkey_that_is_used_for_load_testing_#{n}", push_token:"this_is_a_relatively_long_push_token_that_is_used_for_load_testing_#{n}"}
      PushUser.create_or_update(params)
      puts n if n%1000 == 0
    end
  end
  
  def self.load_test_populate_with_times(first, last)
    tstart = Time.now
    
    (first.to_i..last.to_i).each do |n| 
      puts "-----"
      params = {mkey:"this_is_a_relatively_long_mkey_that_is_used_for_load_testing_#{n}", push_token:"this_is_a_relatively_long_push_token_that_is_used_for_load_testing_#{rand}"}
      t0 = Time.now
      push_user = PushUser.find_by_mkey(params[:mkey])
      t1 = Time.now
      puts "Read time #{1000 * (t1 - t0)}"
      if (push_user)
        push_user.update_attributes(params)
        puts "Update time #{1000 * (Time.now - t1)}"
      else
        PushUser.create(params)
        puts "Create time #{1000 * (Time.now - t1)}"
      end
      
      puts "lpop time #{1000 * (Time.now - t0)}"
      t0 = Time.now
      params[:push_token] = "this_is_a_relatively_long_push_token_that_is_used_for_load_testing_#{rand}"
      PushUser.create_or_update(params)
      puts "createOrUpdate time = #{1000 * (Time.now - t0)}"
    end
    
    ttot = 1000 * (Time.now - tstart)
    puts "=========="
    puts "total = #{ttot} average per = #{ttot / (last.to_i-first.to_i)}"
    
  end
end
