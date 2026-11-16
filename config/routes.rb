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

  resource :week, only: :show do
    resource :reflection, only: :update, module: :weeks
  end

  resource :calendar, only: :show do
    resource :subscription, only: %i[ show update ], module: :calendars
  end
  resources :feeds, only: :show, param: :token

  resources :events, only: %i[ new create edit update destroy ] do
    resources :occurrences, only: [], param: :date, constraints: { occurrence_date: /\d{4}-\d{2}-\d{2}/ } do
      scope module: "events/occurrences" do
        resource :cancellation, only: %i[ create destroy ]
        resources :entries, only: :new
      end
    end
  end

  resource :kids_mode, only: %i[ new create destroy ]
  resource :kids_menu, path: "kids", only: :show
  resources :choices, only: %i[ create show ]
  resource :surprise, only: :create

  resources :pursuits do
    resource :finish, only: %i[ create destroy ], module: :pursuits
  end

  resources :activities do
    scope module: :activities do
      resources :entries, only: :new
      resources :events, only: :new
      resources :pictures, only: :show
    end
  end

  root "home#show"

  resource :up, only: :show, controller: "rails/health"
end
