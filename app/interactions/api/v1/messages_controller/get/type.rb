class Api::V1::MessagesController::Get::Type < Api::BaseInteraction
  ALLOWED_TYPES = %w(video text)

  string :type

  validates :type, inclusion: { in: ALLOWED_TYPES,
                                message: '%{value} is not allowed' }

  def execute
    type
  end
end
