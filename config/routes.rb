Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'registrations' }
  get "mistake_journal/index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Root route
  root "home#index"
  
  # Prompts routes
  resources :prompts, only: [:index, :show] do
    resources :user_responses, only: [:new, :create]
  end
  
  # User responses routes
  resources :user_responses, only: [:show, :index]
  
  # Mistake journal route
  get 'mistake_journal', to: 'mistake_journal#index', as: :mistake_journal
  
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
