require 'sidekiq/web'

ThreebymeServer::Application.routes.draw do
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == Figaro.env.http_basic_username && password == Figaro.env.http_basic_password
  end
  mount Sidekiq::Web => '/sidekiq'

  get 's3_credentials/info'
  get 's3_credentials/videos'
  get 's3_credentials/avatars'

  resources :admin_s3_credentials
  resources :version_compatibilities

  resources :connections
  resources :users do
    get :send_test_message
    post :send_test_message
  end

  resources :connection, only: [] do
    post :set_visibility, on: :collection
  end

  namespace :api do
    namespace :v1 do
      resources :events, only: [:create]
      resources :messages, except: [:new, :edit]
      resources :avatars, only: [:index] do
        collection do
          post :index
          patch :index
          delete :index
        end
      end
    end
  end

  root 'landing#index'
  get 'landing' => 'landing#index'
  get 'l/:id' => 'landing#legacy'
  get 'c/:id' => 'landing#invite'
  get 'privacy' => 'landing#privacy'

  post 'dispatch/post_dispatch'

  get 'users/new_connection/:id' => 'users#new_connection'
  get 'users/establish_connection/:id' => 'users#establish_connection'
  get 'users/receive_test_video/:id' => 'users#receive_test_video', as: :receive_test_video
  get 'users/receive_corrupt_video/:id' => 'users#receive_corrupt_video', as: :receive_corrupt_video
  get 'users/receive_permanent_error_video/:id' => 'users#receive_permanent_error_video', as: :receive_permanent_error_video

  post 'videos/create'
  get 'videos/get'
  get 'videos/delete'

  get 'reg/reg'
  get 'reg/verify_code'
  get 'reg/get_friends'
  get 'reg/debug_get_user'

  post 'notification/set_push_token'
  post 'notification/send_video_received'
  post 'notification/send_video_status_update'

  post 'kvstore/set'
  get 'kvstore/get'
  get 'kvstore/get_all'
  get 'kvstore/delete'
  get 'kvstore/messages'
  get 'kvstore/received_videos'
  get 'kvstore/video_status'

  get 'kvstore_admin' => 'kvstore_admin#index'
  get 'kvstore_admin/delete_all' => 'kvstore_admin#delete_all'

  get 'version/check_compatibility'

  get 'invite_mockup' => 'invite_mockup#index'
  get 'invite_mockup/user/:id' => 'invite_mockup#user'

  get 'invitation/invite'
  get 'invitation/has_app'
  post 'invitation/direct_invite_message'
  post 'invitation/update_friend'

  get 'verification_code/say_code'
  get 'verification_code/call_fallback'

  get 'status', to: 'status#heartbeat'
end
