class User::Decorators::ClientInfo < Zazo::Model::Decorator
  def abilities
    abilities = []
    abilities << 'text_messaging' if text_messaging_allowed?
    abilities
  end

  private

  def text_messaging_allowed?
    device_platform == :android && app_version.to_i >= 173 ||
      device_platform == :ios && app_version.to_i >= 49
  end
end
