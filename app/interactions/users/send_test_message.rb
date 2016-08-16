class Users::SendTestMessage < ActiveInteraction::Base
  object :sender, class: User
  object :receiver, class: User
end
