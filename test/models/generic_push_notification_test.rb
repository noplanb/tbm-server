require 'test_helper'

class GenericPushNotificationTest < ActiveSupport::TestCase
  
  @@SANI_IOS_TOKEN = "de220d693748b309fa8a3bec2237d2ace53a0649f730c2a7f9c353cc672a3ea1"
  @@SANI_NEXUS_RED_TOKEN = "APA91bGWx9OSSxCB9BFeglbocXyzNJ4x9m_2kJDk0y0j8pA59EAPQtBYe5hqu2vvbccUGhm6liLFB91NGUa0tOEehYhYCJLJLnPk5BGCC4hYJk7201tK_nmuVrYcfzhBEspUpdQlRiGWBUHO465ZCMc5MYrlaaYxJQ"
  
  test "Android" do
    gpn = GenericPushNotification.new({
      :platform  => :android, 
      :token =>"APA91bGWx9OSSxCB9BFeglbocXyzNJ4x9m_2kJDk0y0j8pA59EAPQtBYe5hqu2vvbccUGhm6liLFB91NGUa0tOEehYhYCJLJLnPk5BGCC4hYJk7201tK_nmuVrYcfzhBEspUpdQlRiGWBUHO465ZCMc5MYrlaaYxJQ", 
      :payload => {:my_payload => "payload"},
    })
    gpn.send
  end
  
  test "IOS Alert Notification" do
    gpn = GenericPushNotification.new({
      :platform  => :ios, 
      :token => @@SANI_IOS_TOKEN, 
      :type => :alert, 
      :payload => {:my_payload => "payload"},
      :alert => "Alert to ios with badge=3 and sound=default", 
      :badge => 3, 
      :sound => "default", 
      :content_available  => true
    })
    gpn.send
  end
  
  test "IOS Silent Notification" do
    gpn = GenericPushNotification.new({
      :platform  => :ios, 
      :token => @@SANI_IOS_TOKEN, 
      :type => :silent, 
      :payload => {:my_payload => "payload"},
      :content_available  => true
    })
    gpn.send
  end
  
end
