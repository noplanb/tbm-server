class Api::V1::AvatarsController::Update < Api::BaseInteraction
  object :user
  string :use_as_thumbnail

  def execute
    compose(namespace::Shared::UpdateSettings, inputs)
  end
end
