ThreebymeServer::Application.routes.draw do
  get 's3_credentials/info'

  resources :s3_credentials
  resources :connections
  resources :users

  get 'digest/open'
  get 'digest/secure'

  post 'dispatch/post_dispatch'

  get 'users/new_connection/:id' => 'users#new_connection'
  get 'users/establish_connection/:id' => 'users#establish_connection'
  get 'users/receive_test_video/:id' => 'users#receive_test_video'

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
  get 'notification/load_test_send_notification'

  post 'kvstore/set'
  get 'kvstore/get'
  get 'kvstore/get_all'
  get 'kvstore/delete'
  get 'kvstore/load_test_read'
  get 'kvstore/load_test_write'

  get 'kvstore_admin'=> 'kvstore_admin#index'
  get 'kvstore_admin/delete_all'=> 'kvstore_admin#delete_all'

  get 'version/check_compatibility'

  get 'invite_mockup' => 'invite_mockup#index'
  get 'invite_mockup/user/:id' => 'invite_mockup#user'

  get 'invitation/invite'
  get 'invitation/has_app'

  get 'landing' => 'landing#index'
  get 'l/:id' => 'landing#invite'
  get 'landing/test'

  get 'status', to:'status#heartbeat'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
