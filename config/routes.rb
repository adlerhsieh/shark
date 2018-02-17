Rails.application.routes.draw do

  mount Sidekiq::Web => '/sidekiq'

  root "root#show"

end
