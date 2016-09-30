class Users::SendTestMessage::Video < Users::SendTestMessage
  string :file_name

  def execute
    put_s3_object(test_video_id)
  end

  private

  def put_s3_object(video_id)
    cred = S3Credential::Videos.instance
    cred.s3_client.put_object(
      bucket: cred.bucket,
      key: Kvstore.video_filename(sender, receiver, video_id),
      body: File.read(file_path),
      metadata: build_s3_metadata(video_id))
  end

  def build_s3_metadata(video_id)
    { 'client-platform' => 'android',
      'client-version' => '112',
      'sender-mkey' => sender.mkey,
      'receiver-mkey' => receiver.mkey,
      'video-id' =>  video_id,
      'file-size' => File.size(file_path).to_s }
  end

  def test_video_id
    (Time.now.to_f * 1000).to_i.to_s
  end

  def file_path
    Rails.root.join("videos/#{file_name}.mp4")
  end
end
