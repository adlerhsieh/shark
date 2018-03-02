Rails.application.routes.draw do

  mount Sidekiq::Web => '/sidekiq'

  root "admin/fx_signals#index"

  namespace :admin do
    resources :positions do

    end
    resources :fx_signals do

    end
  end

end
