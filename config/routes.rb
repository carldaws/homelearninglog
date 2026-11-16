Rails.application.routes.draw do
  resource :session, only: %i[ new create destroy ]
  resource :registration, only: %i[ new create ]
  resources :passwords, only: %i[ edit update ], param: :token

  resource :family, only: %i[ show new create edit update ] do
    scope module: :families do
      resources :children, only: %i[ new create edit update destroy ]
      resources :memberships, only: :destroy do
        resource :sign_in_link, only: :show, module: :memberships
      end
      resource :invitation, only: :show
    end
  end

  resources :joins, path: "join", only: %i[ show create ], param: :token

  resources :entries, path: "log", only: %i[ index new create edit update destroy ] do
    resources :photos, only: :show, module: :entries
  end

  root "home#show"

  resource :up, only: :show, controller: "rails/health"
end
