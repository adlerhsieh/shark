Rails.application.routes.draw do

  devise_for :users
  mount Sidekiq::Web => '/sidekiq'

  root "root#show"

  namespace :admin do
    resources :orders
    resources :positions
    resources :fx_signals
  end

end
