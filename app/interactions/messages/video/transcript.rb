class Messages::Video::Transcript < ActiveInteraction::Base
  WORKING_DIR = Rails.root.join('videos')

  object :s3_event
  string :message_id
  string :sender_mkey
  string :receiver_mkey

  def execute
    video_path = compose(DownloadVideo, file_path: file_path, s3_event: s3_event)
    audio_path = compose(ExtractAudio, file_path: file_path)
    save_transcription(compose(GetTranscription, audio_path: audio_path))
    remove_files(video_path, audio_path)
  end

  private

  def save_transcription(text)
    Message.create_or_update(
      { sender: sender_mkey, receiver: receiver_mkey,
        message_id: message_id, message_type: 'video' },
      { transcription: text })
  end

  def file_path
    @file_path ||= WORKING_DIR.join(kvstore.key1).to_path
  end

  def remove_files(*files)
    files.each { |f| File.delete(f) if File.exist?(f) }
  end
end
