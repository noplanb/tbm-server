class Api::BaseInteraction < ActiveInteraction::Base
  protected

  def namespace
    self.class.parent
  end
end
