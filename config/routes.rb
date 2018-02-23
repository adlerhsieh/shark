Rails.application.routes.draw do

  mount Sidekiq::Web => '/sidekiq'

  root "admin/fx_signals#index"

  namespace :admin do
    resources :fx_signals do

    end
  end

end
