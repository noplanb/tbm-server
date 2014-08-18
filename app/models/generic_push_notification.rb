require "apns"
require "gcm_server"

class GenericPushNotification
  
  @@APNS_SETTINGS = {
    :host => APP_CONFIG[:apns_host] || "gateway.sandbox.push.apple.com",
    # :host => APP_CONFIG[:apns_host] || "gateway.push.apple.com",
    :pem  => APP_CONFIG[:apns_pem_path] || "#{Rails.root}/certs/tbm_aps_dev.pem",
    :port => APP_CONFIG[:apns_port] || 2195
  }
  
  def self.setup_apns
    @@APNS_SETTINGS.keys.each do |k|
      APNS.send((k.to_s+"=").to_sym, @@APNS_SETTINGS[k])
    end
  end
  
  attr_accessor :platform, :token, :type, :payload,          # ios and android
                :alert, :badge, :sound, :content_available   # ios only
  
  # include EnumHandler
  # define_enum :platform, [:ios,:android]
  # define_enum :type, [:alert, :silent] # Only relevant for ios
  
  def initialize(attrs = {})
    
    @token = attrs[:token] or raise "#{self.class.name}: token required."
    @platform = attrs[:platform].to_sym || :android
    @type = attrs[:type] || :silent
    @alert = attrs[:alert] unless @type == :silent
    @badge = attrs[:badge] unless @type == :silent
    @sound = attrs[:sound] || (@type == :silent ? nil : "default")
    @content_available =  attrs[:content_available] == false ? nil : true  # In our app for ios this should 
    @payload = attrs[:payload]
        
    GenericPushNotification.setup_apns if @platform == :ios
  end
  
  def send
    @platform == :ios ? send_ios : send_android
  end
  
  private
  
  
  def send_ios
    APNS.send_notifications [ios_notification]
  end
  
  def send_android
    GcmServer.send_notification(@token, @payload)
  end
  
  def ios_notification
    n = APNS::Notification.new(@token, {})
    n.alert = @alert if @alert
    n.badge = @badge if @badge
    n.sound = @sound if @sound
    n.content_available = @content_available
    n.other = @payload if @payload
    n
  end
end