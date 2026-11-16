Rails.application.routes.draw do
  resource :session, only: %i[ new create destroy ]
  resource :registration, only: %i[ new create ]
  resource :password, only: %i[ new create ]
  resource :recovery_code, only: :show

  resource :family, only: %i[ show new create edit update ] do
    scope module: :families do
      resources :children, only: %i[ new create edit update destroy ]
      resources :memberships, only: :destroy
      resource :invitation, only: :show
    end
  end

  resources :joins, path: "join", only: %i[ show create ], param: :token

  resources :entries, path: "log", only: %i[ index new create edit update destroy ] do
    resources :photos, only: :show, module: :entries
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

  root "home#show"

  resource :up, only: :show, controller: "rails/health"
end
