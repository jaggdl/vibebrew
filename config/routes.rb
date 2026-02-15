Rails.application.routes.draw do
  resource :signup, only: [ :new, :create ], controller: "signup"
  resource :session
  resource :profile, only: [ :edit, :update ], controller: "profiles"
  resources :team
  resources :passwords, param: :token
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  get "sitemap.xml" => "sitemaps#show", as: :sitemap, defaults: { format: :xml }

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "dashboard#index"

  namespace :coffee_beans do
    resource :search, only: [ :show ], controller: "searches"
  end
  resources :coffee_beans, only: [ :index, :show, :new, :create, :edit, :update, :destroy ] do
    member do
      patch :toggle_favorite
      patch :toggle_rotation
    end
  end
  resources :recipes, only: [ :create, :show, :update, :destroy ] do
    member do
      patch :toggle_favorite
    end
  end
  resources :comments, only: [ :create ] do
    member do
      patch :toggle_publish
    end
  end

  resources :teams do
    member do
      get :switch
      patch :regenerate_invite
    end
    resources :memberships, only: [ :create, :update, :destroy ]
  end

  get "join/:slug/:invite_code", to: "team_invites#show", as: :join_team
  post "join/:slug/:invite_code", to: "team_invites#create"

  scope module: :public do
    resources :beans, only: [ :index, :show ], param: :slug
    resources :brews, only: [ :show ], param: :slug
  end
end
