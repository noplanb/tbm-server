RSpec.shared_context 'user prepared messages' do
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
end
