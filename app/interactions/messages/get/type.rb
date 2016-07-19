class Messages::Get::Type < ActiveInteraction::Base
  ALLOWED_TYPES = %w(video text)

  string :type

  validates :type, inclusion: { in: ALLOWED_TYPES,
                                message: '%{value} is not allowed' }

  def execute
    type
  end
end
