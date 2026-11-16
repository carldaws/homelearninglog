Rails.application.routes.draw do
  resource :session, only: %i[ new create destroy ]
  resource :registration, only: %i[ new create ]
  resources :passwords, only: %i[ edit update ], param: :token

  root "home#show"

  resource :up, only: :show, controller: "rails/health"
end
