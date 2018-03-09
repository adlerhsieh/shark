Rails.application.routes.draw do

  devise_for :users

  authenticate :user, lambda { |u| u.admin?  } do
    mount Sidekiq::Web => '/sidekiq'
  end

  root "root#show"

  namespace :admin do
    resources :account, only: [] do
      collection do
        get :balance
      end
    end
    resources :orders do
      member do
        delete :remove
      end
    end
    resources :positions
    resources :fx_signals
  end

end
