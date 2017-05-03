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
  end
  namespace :user do
  	resources :sessions
    resources :password
    resources :confirmation
    resources :unlock
    resources :registrations
  end
  namespace :api do
    resources :merchants do
      post :upload_picture, on: :collection
    end
  end

end
