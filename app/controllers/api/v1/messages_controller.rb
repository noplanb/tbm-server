class Api::V1::MessagesController < ApiController
  def index
    handle_interactor(:render,
      Messages::Index.run(interactor_params))
  end

  def show
    handle_interactor(:render,
      Messages::Show.run(interactor_params(:id)))
  end

  def create
    handle_interactor([:render, result: false],
      Messages::Create.run(interactor_params(:id, :receiver_mkey, :type, :body, :transcription)))
  end

  def update
    handle_interactor([:render, result: false],
      Messages::Update.run(interactor_params(:id, :sender_mkey, :type, :status)))
  end

  def destroy
    handle_interactor([:render, result: false],
      Messages::Destroy.run(interactor_params(:id)))
  end
end
