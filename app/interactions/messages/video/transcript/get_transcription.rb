class Messages::Video::Transcript::GetTranscription < ActiveInteraction::Base
  NUANCE_API_ENDPOINT = 'https://dictation.nuancemobility.net:443/NMDPAsrCmdServlet/dictation'
  CREDENTIALS_PARAMS = {
    appId:  Figaro.env.nuance_asr_api_id,
    appKey: Figaro.env.nuance_asr_api_key,
    id:     Figaro.env.nuance_asr_id }

  string :audio_path

  def execute
    uri = build_uri
    res = build_http(uri).request(build_request(uri))
    res.code == '200' ? res.body : ''
  end

  private

  def build_uri
    uri = URI(NUANCE_API_ENDPOINT)
    uri.query = URI.encode_www_form(CREDENTIALS_PARAMS)
    uri
  end

  def build_request(uri)
    req = Net::HTTP::Post.new("#{uri.path}?#{uri.query}")
    req.body = File.binread(audio_path)
    req['Content-Type'] = 'audio/x-wav;codec=pcm;bit=16;rate=8000'
    req['Accept-Language'] = 'en_US'
    req['Accept'] = 'text/plain'
    req['Accept-Topic'] = 'Dictation'
    req
  end

  def build_http(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http
  end
end
