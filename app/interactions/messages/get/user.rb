class Messages::Get::User < ActiveInteraction::Base
  string :mkey
  symbol :relation

  def execute
    user = ::User.find_by_mkey(mkey)
    validate_user_presence(user)
    user
  end

  private

  def validate_user_presence(user)
    errors.add(relation.to_sym, "not found by mkey=#{mkey}") unless user
  end
end
