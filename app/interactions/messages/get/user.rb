class Messages::Get::User < ActiveInteraction::Base
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
    errors.add(relation.to_sym, "not found by mkey=#{mkey}")
    false
  end
end