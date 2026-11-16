Rails.application.routes.draw do
  resource :session, only: %i[ new create destroy ]
  resource :registration, only: %i[ new create ]
  resource :password, only: %i[ new create ]
  resource :recovery_code, only: :show

  resources :children, only: %i[ show new create edit update destroy ] do
    resources :entries, only: %i[ new create edit update destroy ] do
      resources :photos, only: :show, module: :entries
    end

    resource :calendar, only: :show do
      resource :subscription, only: %i[ show update ], module: :calendars
    end

    resources :events, only: %i[ new create edit update destroy ] do
      resources :occurrences, only: [], param: :date, constraints: { occurrence_date: /\d{4}-\d{2}-\d{2}/ } do
        scope module: "events/occurrences" do
          resource :cancellation, only: %i[ create destroy ]
          resources :entries, only: :new
        end
      end
    end

    resources :ideas, only: [] do
      scope module: :ideas do
        resource :set_aside, only: :create
        resources :entries, only: :new
      end
    end

    resources :accesses, path: "grown-ups", only: %i[ index destroy ]
  end

  resources :invitations, only: %i[ new create show ]
  resources :joins, path: "join", only: %i[ show create ], param: :token
  resources :feeds, only: :show, param: :token

  root "home#show"

  resource :up, only: :show, controller: "rails/health"
end
