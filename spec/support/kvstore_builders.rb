module KvstoreBuilders
  def gen_video_id
    (Time.now.to_f * 1000).to_i.to_s
  end

  def gen_message_id
    gen_video_id
  end
end

RSpec.configure do |config|
  config.include KvstoreBuilders
end
