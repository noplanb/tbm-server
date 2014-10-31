ThreebymeServer::Application.routes.draw do

  resources :connections
  resources :users
  
  get 'users/new_connection/:id' => 'users#new_connection'
  get 'users/establish_connection/:id' => 'users#establish_connection'
  get 'users/receive_test_video/:id' => 'users#receive_test_video'

  post 'videos/create'
  get 'videos/get'
  get 'videos/delete'
  
  get 'reg/reg'
  get 'reg/verify_code'
  get 'reg/get_friends'

  post 'notification/set_push_token'
  post 'notification/send_video_received'
  post 'notification/send_video_status_update'
  
  post 'kvstore/set'
  get 'kvstore/get'
  get 'kvstore/get_all'
  get 'kvstore/delete'

  get 'version/check_compatibility'
  
  get 'invite_mockup' => 'invite_mockup#index'
  get 'invite_mockup/user/:id' => 'invite_mockup#user'
  
  get 'invitation/invite'
  
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
