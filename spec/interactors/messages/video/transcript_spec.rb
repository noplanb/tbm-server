require 'rails_helper'

RSpec.describe Messages::Video::Transcript do
  let(:sender_mkey) { 'YRn7ZUDIZI3WzdKT8WxA' }
  let(:receiver_mkey) { 'FaGUU1xx60N2cOufnV1v' }
  let(:message_id) { '1470241221531' }
  let(:transcription) { 'How are you?' }
  let(:s3_event) do
    s3_event = S3Event.new
    s3_event.bucket_name = 'staging-videos.zazo.com'
    s3_event.file_name = "#{sender_mkey}-#{receiver_mkey}-75bfb6260039c15220e9d96e60eeff51"
    s3_event
  end
  let(:params) do
    { s3_event: s3_event, message_id: message_id,
      sender_mkey: sender_mkey, receiver_mkey: receiver_mkey }
  end

  describe '.run' do
    subject { described_class.run(params) }

    before do
      allow_any_instance_of(Messages::Video::Transcript::DownloadVideo).to(
        receive(:execute).and_return("#{s3_event.file_name}.mp4"))
      allow_any_instance_of(Messages::Video::Transcript::ExtractAudio).to(
        receive(:execute).and_return("#{s3_event.file_name}.wav"))
      allow_any_instance_of(Messages::Video::Transcript::GetTranscription).to(
        receive(:execute).and_return(transcription))
    end

    context 'when message metadata is not exist' do
      it { expect { subject }.to change { Message.count }.by(1) }
      it { subject; expect(Message.last.transcription).to eq(transcription) }
    end

    context 'when message metadata is already exist' do
      before do
        create(:message,
          sender: sender_mkey, receiver: receiver_mkey, message_id: message_id)
      end

      it { expect { subject }.to change { Message.count }.by(0) }
      it { subject; expect(Message.last.transcription).to eq(transcription) }
    end
  end
end
