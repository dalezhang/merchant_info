Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: 'users/sessions', registrations: 'users/registrations', passwords: 'users/passwords' }
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Serve websocket cable requests in-process
  # mount ActionCable.server => '/cable'

  root to: "home#index"

  resources :product_drafts do
    resources :variants do
    end
    get :csv, on: :collection
    post :import, :import_from_google_docs, on: :collection
  end
  resources :examine_product_drafts do
    post :toggle_examine, on: :member
  end

end
