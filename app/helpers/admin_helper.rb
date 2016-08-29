module AdminHelper
  def connected_users(user)
    user.connected_users.map do |u|
      { user: u, connection: Connection.live_between(user.id, u.id).first }
    end.sort { |d1,d2| d1[:connection].created_at <=> d2[:connection].created_at }
  end

  def test_video_messages
    [
      { name: 'Test Video Sani', files: %w(test_video_sani) },
      { name: 'Test Video Sani Long', files: %w(test_video_sani_long) },
      { name: 'Test Video 1 Long', files: %w(test_video_1) },
      { name: 'Test Video 2', files: %w(test_video_2) },
      { name: 'Test Video 3', files: %w(test_video_3) },
      { name: 'All Previous Videos', files: %w(test_video_sani test_video_sani_long test_video_1 test_video_2 test_video_3) }
    ]
  end
end
