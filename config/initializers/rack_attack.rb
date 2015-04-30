class Rack::Attack
  whitelist('allow from localhost') do |req|
    # Requests are allowed if the return value is truthy
    '127.0.0.1' == req.ip
  end
  whitelist('allow ELB health checker') do |req|
    # Requests are allowed if the return value is truthy
    req.user_agent.try(:include?, 'ELB-HealthChecker')
  end
  blacklist('block non-allowed hosts') do |req|
    # Requests are blocked if the return value is truthy
    zones = ['.dev', '.xip.io', '.elasticbeanstalk.com', '.zazoapp.com', '192.168.1.82']
    !([Figaro.env.domain_name, 'zazoapp.com'].include?(req.host) ||
     zones.any? { |d| req.host.ends_with?(d) })
  end
end

ActiveSupport::Notifications.subscribe('rack.attack') do |name, start, finish, _request_id, req|
  match_type = req.env['rack.attack.match_type']
  if match_type.present? && match_type != :whitelist
    Rails.logger.info "[#{name} #{match_type}] (#{start} - #{finish}) #{req.inspect}"
  end
end
