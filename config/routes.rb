Rails.application.routes.draw do
  resource :up, only: :show, controller: "rails/health"
end
