class GenericPushNotification
  # :build = :dev, :prod (for IOS only)
  attr_accessor :platform, :token, :type, :payload,          # ios and android
                :alert, :badge, :sound, :content_available, :build   # ios only

  # include EnumHandler
  # define_enum :platform, [:ios,:android]
  # define_enum :type, [:alert, :silent] # Only relevant for ios

  def initialize(attrs = {})
    @build = attrs[:build] || :dev
    @token = attrs[:token] or fail "#{self.class.name}: token required."
    @platform = attrs[:platform] || :android
    @type = attrs[:type] || :silent
    @alert = attrs[:alert] unless @type == :silent
    @badge = attrs[:badge] unless @type == :silent
    @sound = attrs[:sound] || (@type == :silent ? nil : 'NotificationTone.wav')
    @content_available =  attrs[:content_available] == false ? nil : true  # In our app for ios this should
    @payload = attrs[:payload]
  end

  def ios_notification
    n = Houston::Notification.new(device: @token)
    n.alert = @alert if @alert
    n.badge = @badge if @badge
    n.sound = @sound if @sound
    n.content_available = @content_available
    n.custom_data = @payload if @payload
    n
  end

  def send
    @platform == :ios ? send_ios : send_android
  end

  def feedback
    apns.devices
  end

  private

  def send_ios
    apns.push ios_notification
  end

  def apns
    if @build == :prod
      client = Houston::Client.production
      client.certificate = File.read(Rails.root.join('certs/zazo_aps_prod.pem'))
    else
      client = Houston::Client.development
      client.certificate = File.read(Rails.root.join('certs/zazo_aps_dev.pem'))
    end
    client
  end

  def send_android
    GcmServer.send_notification(@token, @payload)
  end
end
