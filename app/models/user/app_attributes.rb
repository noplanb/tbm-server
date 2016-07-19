module User::AppAttributes
  def only_app_attrs_for_user
    r = attributes.symbolize_keys.slice(:id, :auth, :mkey, :first_name, :last_name,
                                        :mobile_number, :device_platform, :emails)
    r[:id] = r[:id].to_s
    r
  end

  def only_app_attrs_for_friend
    r = attributes.symbolize_keys.slice(:id, :mkey, :first_name, :last_name,
                                        :mobile_number, :device_platform, :emails)
    r[:id] = r[:id].to_s
    r[:has_app] = app?.to_s
    r
  end

  def only_app_attrs_for_friend_with_ckey(connected_user)
    conn = Connection.live_between(id, connected_user.id).first
    fail 'No connection found with connected user. This should never happen.' if conn.nil?
    only_app_attrs_for_friend.merge(ckey: conn.ckey,
                                    cid: conn.id.to_s,
                                    connection_created_on: conn.created_at,
                                    connection_creator_mkey: conn.creator.mkey,
                                    connection_status: conn.status)
  end
end
