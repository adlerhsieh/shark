Rails.application.routes.draw do

  devise_for :users

  authenticate :user, lambda { |u| u.admin?  } do
    mount Sidekiq::Web => '/sidekiq'
  end

  root "root#show"

  namespace :admin do
    resources :orders
    resources :positions
    resources :fx_signals
  end

end
