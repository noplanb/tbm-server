class Messages::Video::Transcript < ActiveInteraction::Base
  WORKING_DIR = Rails.root.join('videos')

  object :kvstore
  object :s3_event

  def execute
    video_path = compose(DownloadVideo, s3_event: s3_event, file_path: file_path)
    audio_path = compose(ExtractAudio, file_path: file_path)
    update_record(transcription: compose(GetTranscription, audio_path: audio_path))
    remove_files(video_path, audio_path)
  end

  private

  def update_record(data)
    new_value = JSON.parse(kvstore.value).merge(data)
    kvstore.update_attributes(value: new_value.to_json)
  end

  def file_path
    @file_path ||= WORKING_DIR.join(kvstore.key1).to_path
  end

  def remove_files(*files)
    files.each { |f| File.delete(f) if File.exist?(f) }
  end
end
