Rails.application.routes.draw do

  devise_for :users

  authenticate :user, lambda { |u| u.admin?  } do
    mount Sidekiq::Web => '/sidekiq'
  end

  root "root#show"

  namespace :admin do

    resources :reports, only: %i[index] do
      collection do
        get :balance
      end
    end
    resources :account, only: %i[] do
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
