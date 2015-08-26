require 'rails_helper'

RSpec.describe DocumentationController, type: :controller do
  def full_path(path)
    Rails.root.join('doc', path)
  end

  def file_content(full_path)
    File.read full_path
  end

  before { authenticate_with_http_basic }

  describe 'GET #show' do
    context '/documentation/api' do
      it 'render doc/api.html' do
        get :show, id: 'api'
        expect(response.body).to eq(file_content(full_path('api.html')))
      end
    end
    context '/documentation/api.html' do
      it 'render doc/api.html' do
        get :show, id: 'api', format: 'html'
        expect(response.body).to eq(file_content(full_path('api.html')))
      end
    end
    context '/documentation/todo.txt' do
      it 'render doc/todo.txt' do
        get :show, id: 'todo', format: 'txt'
        expect(response.body).to eq(file_content(full_path('todo.txt')))
      end
    end
    context '/documentation/not_exists.txt' do
      it 'respond with :not_found' do
        get :show, id: 'not_exists', format: 'txt'
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
