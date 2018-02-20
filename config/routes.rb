Rails.application.routes.draw do

  mount Sidekiq::Web => '/sidekiq'

  root "root#show"

  namespace :admin do
    resources :fx_signals do

    end
  end

end
