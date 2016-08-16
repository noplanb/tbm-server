class Users::SendTestMessage::Video < Users::SendTestMessage
  string :file_name
  boolean :s3_upload, default: true

  def execute
    kvstore_record = Kvstore.add_id_key(sender, receiver, create_test_video)
    Notifications::Send::Received.run(
      sender: sender, receiver: receiver, kvstore: kvstore_record)
  end

  private

  def create_test_video
    video_id = test_video_id
    put_s3_object(video_id, Rails.root.join("#{file_name}.mp4")) if s3_upload
    video_id
  end

  def put_s3_object(video_id, file_path)
    cred = S3Credential.instance
    cred.s3_client.put_object(
      bucket: cred.bucket,
      key: Kvstore.video_filename(sender, receiver, video_id),
      body: File.read(file_path),
      metadata: build_s3_metadata(video_id))
  end

  def build_s3_metadata(video_id)
    { 'sender-mkey' => sender.mkey,
      'receiver-mkey' => receiver.mkey,
      'video-id' =>  video_id }
  end

  def test_video_id
    (Time.now.to_f * 1000).to_i.to_s
  end
end
