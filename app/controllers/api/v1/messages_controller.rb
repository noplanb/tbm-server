class Api::V1::MessagesController < ApiController
  def index
    handle_interactor(:render,
      Messages::Index.run(user: current_user))
  end

  def show
    handle_interactor(:render,
      Messages::Show.run(user: current_user, id: params[:id]))
  end

  def create
    handle_interactor([:render, result: false],
      Messages::Create.run(params.merge(user: current_user)))
  end

  def update
    handle_interactor([:render, result: false],
      Messages::Update.run(user: current_user, id: params[:id], status: params[:status]))
  end

  def delete
    handle_interactor([:render, result: false],
      Messages::Delete.run(user: current_user, id: params[:id]))
  end
end
