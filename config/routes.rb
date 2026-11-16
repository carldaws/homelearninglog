Rails.application.routes.draw do
  root "home#show"

  resource :up, only: :show, controller: "rails/health"
end
