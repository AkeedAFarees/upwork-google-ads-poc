Rails.application.routes.draw do
  root 'home#index'

  get 'home/index'
  post 'set_credentials', to: 'home#set_credentials', as: :set_credentials
  get 'setup', to: 'home#setup', as: :setup

  get "/auth/:provider/callback" => 'omniauth_callbacks#google_oauth2'
  get 'logout', to: 'omniauth_callbacks#logout', as: :logout

  resources :campaigns, only: [:index, :create, :show] do
    post 'create_ad_group', on: :member
    post :create_ad, on: :member
  end
end
