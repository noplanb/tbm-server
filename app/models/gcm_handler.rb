module GcmHandler
  extend self
  
  API_KEY = "AIzaSyDSFYoue4kZiz9Fx1W9DSr03tMO-Pfl54Q"
  SANI_HTC_TOKEN = "APA91bGHhfj80F-guuyyGchNWSDvQtMbjt1QYKe7KyTy-QKbDzNZA_ILBBrq4yJn_k_Ayx8-dyVlPf6yyuzDpiW207LudcCwn-KRd0NPLJUuSTjQK6RbNJFMZpMnviQf_mawfCbqD3LSavGNR-HRiOdhNeaTVmgdoQ"
    
  def send(ids)
    gcm = GCM.new(API_KEY)
    options = {data: {from: "2"}}
    response =  gcm.send_notification(ids, options)
  end
  
  def send_for_video(video)
    to_ids = [User.find(video.receiver_id).push_token]
    # puts "to_ids: #{to_ids.inspect}"
    from = video.user_id.to_s
    # options = {data: {from: from}, collapse_key: from}
    options = {data: {from_id: from}, collapse_key: from}
    # puts "options: #{options.inspect}"
    # puts "API_KEY: #{API_KEY}"
    gcm = GCM.new(API_KEY)
    return gcm.send_notification(to_ids, options)
  end
  
  def test_send()
    send [SANI_HTC_TOKEN]
  end
  
end
