# Using papertrailapp.com for app logs management

def Rails.syslogger
  RemoteSyslogLogger.new(ENV['papertrail_host'], ENV['papertrail_port'],
                         program: ENV['papertrail_program'], local_hostname: ENV['papertrail_local_hostname'])
end
