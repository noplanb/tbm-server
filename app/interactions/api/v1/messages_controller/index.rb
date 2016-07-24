class Api::V1::MessagesController::Index < Api::BaseInteraction
  object :user

  def execute
    merge_by_mkey(:abilities,
      Kvstore::GetMessages.new(user).call, friends_abilities)
  end

  private

  def merge_by_mkey(field, array, hash)
    array.map { |row| row.merge(field => hash[row[:mkey]]) }
  end

  def friends_abilities
    user.connected_users.each_with_object({}) do |friend, memo|
      memo[friend.mkey] = user.decorate_with(:client_info).abilities
    end
  end
end
