class GcmHandler
  
  
  API_KEY = "AIzaSyDSFYoue4kZiz9Fx1W9DSr03tMO-Pfl54Q"
  SANI_HTC_TOKEN = "APA91bGHhfj80F-guuyyGchNWSDvQtMbjt1QYKe7KyTy-QKbDzNZA_ILBBrq4yJn_k_Ayx8-dyVlPf6yyuzDpiW207LudcCwn-KRd0NPLJUuSTjQK6RbNJFMZpMnviQf_mawfCbqD3LSavGNR-HRiOdhNeaTVmgdoQ"
  
  def initialize()
    @gcm = GCM.new(API_KEY)
  end
  
  def send(ids)
    options = {data: {score: "123"}, collapse_key: "updated_score"}
    response =  @gcm.send_notification(ids, options)
  end
  
  def test_send()
    send [SANI_HTC_TOKEN]
  end
  
end
