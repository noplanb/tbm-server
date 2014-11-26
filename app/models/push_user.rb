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
    (first.to_i..last.to_i).each{|n| PushUser.create_or_update mkey:"this_is_a_relatively_long_mkey_that_is_used_for_load_testing_#{n}", push_token:"this_is_a_relatively_long_push_token_that_is_used_for_load_testing_#{n}"}
  end
end
