class PushUser < ActiveRecord::Base
  include EnumHandler
  
  define_enum :device_platform, [:ios,:android], :primary => true
  define_enum :device_build, [:dev,:prod]
  
  def self.create_or_update(params)
    if push_user = PushUser.find_by_mkey(params[:mkey])
      [:push_token, :device_platform, :device_build].each do |key|
        push_user.send("#{key}=".to_sym, params[key])
      end
      push_user.save
    else
      PushUser.create(params)
    end
  end
  
  
  # ================
  # = Load Testing =
  # ================
  
  def self.load_test_populate(first, last)
    tstart = Time.now
    
    (first.to_i..last.to_i).each do |n| 
      puts "-----"
      params = {mkey:"this_is_a_relatively_long_mkey_that_is_used_for_load_testing_#{n}", push_token:"this_is_a_relatively_long_push_token_that_is_used_for_load_testing_#{n}"}
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
      PushUser.create_or_update(params)
      puts "createOrUpdate time = #{1000 * (Time.now - t0)}"
    end
    
    ttot = 1000 * (Time.now - tstart)
    puts "=========="
    puts "total = #{ttot} average per = #{ttot / (last.to_i-first.to_i)}"
    
  end
end
