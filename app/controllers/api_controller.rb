class ApiController < ApplicationController
  before_action :authenticate

  def handle_interactor(type_settings, interactor, &callback)
    Controllers::HandleApiInteractor.new(
      context: self, interactor: interactor,
      type_settings: type_settings, callback: callback).call do |handler|
      handler.render? ? render(handler.response) : handler.result
    end
  end
end
