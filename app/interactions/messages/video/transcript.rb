class Messages::Video::Transcript < ActiveInteraction::Base
  WORKING_DIR = Rails.root.join('videos')

  object :kvstore
  object :s3_event

  def execute
    file_path = WORKING_DIR.join(kvstore.key1).to_path
    video = compose(DownloadVideo, s3_event: s3_event, file_path: file_path)
    audio = compose(ExtractAudio, file_path: file_path)
    update_record(transcription: get_transcription)
    remove_files(video, audio)
  end

  private

  def get_transcription

  end

  def update_record(data)

  end

  def remove_files(*files)
    files.each { |f| File.delete(f) if File.exist?(f) }
  end
end
