class Messages::Video::Transcript::ExtractAudio < ActiveInteraction::Base
  string :file_path

  def execute
    video_path = file_path + '.mp4'
    audio_path = file_path + '.wav'
    transcode(video_path, audio_path, transcode_options)
    audio_path
  end

  private

  def transcode(input, output, options)
    movie = FFMPEG::Movie.new(input)
    movie.transcode(output, options, timeout: 5)
  end

  def transcode_options
    '-vn -acodec pcm_s16le -ar 8000 -ac 1'
  end
end
