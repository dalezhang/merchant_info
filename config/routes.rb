Rails.application.routes.draw do
  # devise_for :users, controllers: { sessions: 'users/sessions', registrations: 'users/registrations', passwords: 'users/passwords' }
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Serve websocket cable requests in-process
  # mount ActionCable.server => '/cable'

  root to: "home#index"

  resources :merchants do
    post :upload_picture, on: :member
  end
  resources :inspect_merchants do
    post :change_status, :change_pay_route_status, :prepare_request,
          :update_backend_account, 
          :zx_infc, :pfb_infc, :create_pay_route, on: :member
    get :get_merchant_id, :get_backend_account, :routes, :add_route, on: :member
    resources :zx_contr_info_lists
  end
  namespace :user do
  	resources :sessions
    resources :password do
      post :reset_password, :send_reset_email, on: :collection
    end
    resources :confirmation
    resources :unlock
    resources :registrations
  end
  resources :users
  resources :upload_img, only: [:index]
  resources :error_logs
  namespace :api do
    resources :merchants
  end
  resources :test do
    get  :zx_appid, on: :collection 
    post :wechat_cert, on: :collection
  end
  resources :agents

end
