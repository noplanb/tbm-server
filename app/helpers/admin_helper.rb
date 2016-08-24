module AdminHelper
  def connected_users(user)
    user.connected_users.map do |u|
      { user: u, connection: Connection.live_between(user.id, u.id).first }
    end.sort { |d1,d2| d1[:connection].created_at <=> d2[:connection].created_at }
  end
end
