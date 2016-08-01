module SidekiqWorker
  class TranscriptVideoMessage
    include Sidekiq::Worker

    def perform(kvstore_id, s3_event_raw)
      Messages::Video::Transcript.run!(
        kvstore: Kvstore.find(kvstore_id), s3_event: S3Event.new(s3_event_raw))
    end
  end
end
