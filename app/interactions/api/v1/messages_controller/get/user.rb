class Api::V1::MessagesController::Get::User < Api::BaseInteraction
  string :mkey
  symbol :relation

  def execute
    user = ::User.find_by_mkey(mkey)
    validate_presence(user)
    user
  end

  private

  def validate_presence(user)
    return true if user
    errors.add(relation.to_sym, "is not found by mkey=#{mkey}")
    false
  end
end
