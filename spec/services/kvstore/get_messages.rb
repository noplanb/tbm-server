require 'rails_helper'

RSpec.describe Kvstore::GetMessages do
  include_context 'user prepared messages'

  let(:user) { create(:user) }
  let(:instance) { described_class.new(user) }

  describe '#call' do
    subject { instance.call(filter: filter) }

    context 'all messages' do
      let(:filter) { nil }

      it do
        expected = [
          { mkey: friend_1.mkey,
            statuses: [{ type: 'video', message_id: message_12, status: 'downloaded' }],
            messages: [
              { type: 'text', message_id: message_11, body: 'Message 11' },
              { type: 'text', message_id: message_12, body: 'Message 12' },
              { type: 'video', message_id: message_13 }
            ] },
          { mkey: friend_2.mkey,
            statuses: [{ type: 'video', message_id: message_23, status: 'viewed' }],
            messages: [
              { type: 'text', message_id: message_21, body: 'Message 21' },
              { type: 'text', message_id: message_22, body: 'Message 22' },
              { type: 'text', message_id: message_23, body: 'Message 23' }
            ] },
          { mkey: friend_3.mkey,
            statuses: [],
            messages: [] },
          { mkey: friend_4.mkey,
            statuses: [{ type: 'text', message_id: message_41, status: 'downloaded' }],
            messages: [
              { type: 'video', message_id: message_41 },
              { type: 'video', message_id: message_42 },
              { type: 'video', message_id: message_43 }
            ] },
          { mkey: friend_5.mkey,
            statuses: [{ type: 'video', message_id: message_52, status: 'viewed' }],
            messages: [] }
        ]
        is_expected.to match_array(expected)
      end
    end
  end

  context 'legacy methods' do
    describe '#received_videos' do
      it do
        expected = [
          { mkey: friend_1.mkey, video_ids: [message_13] },
          { mkey: friend_2.mkey, video_ids: [] },
          { mkey: friend_3.mkey, video_ids: [] },
          { mkey: friend_4.mkey, video_ids: [message_41, message_42, message_43] },
          { mkey: friend_5.mkey, video_ids: [] }
        ]
        expect(instance.legacy(:received_videos)).to match_array(expected)
      end
    end

    describe '#video_status' do
      it do
        expected = [
          { mkey: friend_1.mkey, video_id: message_12, status: 'downloaded' },
          { mkey: friend_2.mkey, video_id: message_23, status: 'viewed' },
          { mkey: friend_3.mkey, video_id: '', status: '' },
          { mkey: friend_4.mkey, video_id: '', status: '' },
          { mkey: friend_5.mkey, video_id: message_52, status: 'viewed' }
        ]
        expect(instance.legacy(:video_status)).to match_array(expected)
      end
    end
  end
end
