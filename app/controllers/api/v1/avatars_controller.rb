class Api::V1::AvatarsController < ApiController
  def index
    case request.method
      when 'POST'   then create
      when 'PATCH'  then update
      when 'DELETE' then destroy
      else
        handle_interactor(:render,
          Index.run(interactor_params))
    end
  end

  private

  def create
    handle_interactor([:render, result: false],
      Create.run(interactor_params(:avatar, :use_as_thumbnail)))
  end

  def update
    handle_interactor([:render, result: false],
      Update.run(interactor_params(:use_as_thumbnail)))
  end

  def destroy
    handle_interactor([:render, result: false],
      Destroy.run(interactor_params))
  end
end
