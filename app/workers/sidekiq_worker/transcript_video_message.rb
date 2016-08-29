module SidekiqWorker
  class TranscriptVideoMessage
    include Sidekiq::Worker

    def perform(s3_event_raw, sender_mkey, receiver_mkey, message_id)
      Messages::Video::Transcript.run!(
        s3_event: S3Event.new(s3_event_raw), message_id: message_id,
        sender_mkey: sender_mkey,receiver_mkey: receiver_mkey)
    end
  end
end
