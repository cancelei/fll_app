Rails.application.routes.draw do
  # Define routes with locale scope
  scope "(:locale)", locale: /#{I18n.available_locales.join('|')}/ do
    devise_for :users, controllers: { registrations: "registrations" }
    get "mistake_journal/index"

    # User preferences routes
    get "user_preferences/edit", as: :edit_user_preferences
    patch "user_preferences/update", as: :update_user_preferences
    # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

    # Root route
    root "home#index"

    # Prompts routes
    resources :prompts, only: [ :index, :show ] do
      collection do
        get :debug_seed
      end
      resources :user_responses, only: [ :new, :create ]
    end

    # User responses routes
    resources :user_responses, only: [ :show, :index ]

    # Mistake journal routes
    get "mistake_journal", to: "mistake_journal#index", as: :mistake_journal
    patch "mistake_journal/:id/mark_resolved", to: "mistake_journal#mark_resolved", as: :mark_mistake_resolved
    patch "mistake_journal/:id/mark_unresolved", to: "mistake_journal#mark_unresolved", as: :mark_mistake_unresolved
  end

  # Redirect root to default locale
  get "/", to: redirect("/#{I18n.default_locale}"), constraints: lambda { |req| !req.path.match(/^\/(#{I18n.available_locales.join('|')})/) }

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
