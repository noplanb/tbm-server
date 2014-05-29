module GcmServer
  
  extend self
  require 'json'
  include NpbNotification 
  
  URI = "https://android.googleapis.com/gcm/send"
  API_KEY = "AIzaSyDSFYoue4kZiz9Fx1W9DSr03tMO-Pfl54Q"
  SANI_HTC_TOKEN = "APA91bGHhfj80F-guuyyGchNWSDvQtMbjt1QYKe7KyTy-QKbDzNZA_ILBBrq4yJn_k_Ayx8-dyVlPf6yyuzDpiW207LudcCwn-KRd0NPLJUuSTjQK6RbNJFMZpMnviQf_mawfCbqD3LSavGNR-HRiOdhNeaTVmgdoQ"
    
  def test
    send_notification(SANI_HTC_TOKEN, {from_id: "2"})
  end
  
  def send_notification(ids, data)
    post_to_gcm( make_payload(ids, data) )
  end
    
  def post_to_gcm(payload)
    Rails.logger.info "GcmServer: Attempting to send notification. #{payload.inspect}"
    
    payload = payload.to_json unless payload.class == String
    
    uri = URI(URI)    
    req = Net::HTTP::Post.new(uri.path)
    req.body = payload
    req["Authorization"] = "key=#{API_KEY}"
    req["Content-Type"] = "application/json"
    
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    
    res =  http.request(req)
    if res.code != "200"
      Rails.logger.error res.body.inspect
    else
      j = JSON.parse res.body
      if j["failure"] != 0 || j["canonical_ids"] != 0
        Rails.logger.error JSON.pretty_generate j
      else
        Rails.logger.info "GcmServer: succesfully sent notification. #{payload.inspect}"
      end
    end
    return res
  end
  
  def make_payload(ids, data)
    ids = Array(ids)
    return {registration_ids: ids, data: data}
  end
  
end
