Rails.application.routes.draw do
  resource :session, only: %i[ new create destroy ]
  resource :registration, only: %i[ new create ]
  resource :password, only: %i[ new create ]
  resource :recovery_code, only: :show

  resources :children, only: %i[ show new create edit update destroy ] do
    resource :log, only: :show

    resources :entries, only: %i[ new create edit update destroy ] do
      scope module: :entries do
        resources :photos, only: :show
        resources :comments, only: %i[ create edit update destroy ]
      end
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
        resource :set_aside, only: %i[ create destroy ]
        resources :entries, only: :new
      end
    end

    resource :settings, path: "manage", only: :show
    resource :removal, only: :new
    resources :accesses, path: "grown-ups", only: :destroy
  end

  direct :entry_in_log do |entry|
    route_for :child_log, entry.child_id, through: entry.happened_on.iso8601, anchor: ActionView::RecordIdentifier.dom_id(entry)
  end

  resources :invitations, only: %i[ new create show ]
  resources :joins, path: "join", only: %i[ show create ], param: :token
  resources :feeds, only: :show, param: :token

  root "home#show"

  resource :up, only: :show, controller: "rails/health"
end
