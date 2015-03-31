module GcmServer
  extend self
  require 'json'
  include NpbNotification

  GCM_URI = 'https://android.googleapis.com/gcm/send'

  # Key created at console.developers.google.com under project ThreeByMe.
  # currently tbm beta server and andrey server using this key for

  # Key created at console.developers.google.com under project Zazo.
  # This key should be used for development, staging, & production servers.
  # This account is set up so that any host may present this key. It does not have a white list
  # of ip addresses.

  def send_notification(ids, data)
    post_to_gcm(make_payload(ids, data))
  end

  def post_to_gcm(payload)
    Rails.logger.info "GcmServer: Attempting to send notification. #{payload.inspect}"

    response = connection.post do |req|
      req.body = payload
    end

    if response.body['failure'] != 0 || response.body['canonical_ids'] != 0
      Rails.logger.error JSON.pretty_generate(response.body)
    else
      Rails.logger.info "GcmServer: succesfully sent notification. #{payload.inspect}"
    end
    response
  end

  def make_payload(ids, data)
    { registration_ids: Array(ids), data: data }
  end

  def connection
    @connection ||= Faraday.new(GCM_URI) do |c|
      c.request :json
      c.response :json, content_type: /\bjson$/
      c.response :raise_error
      c.headers['Authorization'] = "key=#{Figaro.env.gcm_api_key}"
      c.adapter Faraday.default_adapter
    end
  end
end
