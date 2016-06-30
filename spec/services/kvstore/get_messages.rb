require 'rails_helper'

RSpec.describe Kvstore::GetMessages do
  let(:user) { create(:user) }
  let(:instance) { described_class.new(user: user) }

  let!(:friend_1) { create(:established_connection, creator: user).target }
  let!(:friend_2) { create(:established_connection, creator: user).target }
  let!(:friend_3) { create(:established_connection, creator: user).target }
  let!(:friend_4) { create(:established_connection, creator: user).target }
  let!(:friend_5) { create(:established_connection, creator: user).target }

  let!(:message_11) { Kvstore.add_message_id_key('text', friend_1, user, gen_message_id, body: 'Message 11').key2 }
  let!(:message_12) { Kvstore.add_message_id_key('text', friend_1, user, gen_message_id, body: 'Message 12').key2 }
  let!(:message_13) { Kvstore.add_message_id_key('video', friend_1, user, gen_message_id).key2 }
  let!(:message_21) { Kvstore.add_message_id_key('text', friend_2, user, gen_message_id, body: 'Message 21').key2 }
  let!(:message_22) { Kvstore.add_message_id_key('text', friend_2, user, gen_message_id, body: 'Message 22').key2 }
  let!(:message_23) { Kvstore.add_message_id_key('text', friend_2, user, gen_message_id, body: 'Message 23').key2 }
  let!(:message_41) { Kvstore.add_message_id_key('video', friend_4, user, gen_message_id).key2 }
  let!(:message_42) { Kvstore.add_id_key(friend_4, user, gen_message_id).key2 }
  let!(:message_43) { Kvstore.add_id_key(friend_4, user, gen_message_id).key2 }
  let!(:message_51) { gen_message_id }
  let!(:message_52) { gen_message_id }

  before do
    Kvstore.add_status_key(user, friend_1, message_11, 'downloaded')
    Kvstore.add_status_key(user, friend_1, message_12, 'downloaded')
    Kvstore.add_status_key(user, friend_2, message_21, 'downloaded')
    Kvstore.add_status_key(user, friend_2, message_22, 'viewed')
    Kvstore.add_status_key(user, friend_2, message_23, 'viewed')
    Kvstore.add_message_status_key('text', user, friend_4, message_41, 'downloaded')
    Kvstore.add_message_status_key('text', user, friend_5, message_51, 'viewed')
    Kvstore.add_message_status_key('video', user, friend_5, message_52, 'viewed')
  end

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

    xcontext 'video messages' do
      let(:filter) { 'video' }

      it do
        expected = [
          { mkey: friend_1.mkey,
            statuses: [{ type: 'video', message_id: message_12, status: 'downloaded' }],
            messages: [
              { type: 'video', message_id: message_13 }
            ] },
          { mkey: friend_2.mkey,
            statuses: [{ type: 'video', message_id: message_23, status: 'viewed' }],
            messages: [] },
          { mkey: friend_3.mkey,
            statuses: [],
            messages: [] },
          { mkey: friend_4.mkey,
            statuses: [],
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

    xcontext 'text messages' do
      let(:filter) { 'text' }

      it do
        expected = [
          { mkey: friend_1.mkey,
            statuses: [],
            messages: [
              { type: 'text', message_id: message_11, body: 'Message 11' },
              { type: 'text', message_id: message_12, body: 'Message 12' }
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
