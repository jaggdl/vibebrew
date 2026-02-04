Saas::Engine.routes.draw do
  get "pricing", to: "checkout#new"
  post "checkout", to: "checkout#create"
  get "checkout/success", to: "checkout#success"
  get "checkout/cancel", to: "checkout#cancel"

  post "webhooks/stripe", to: "webhooks#stripe"

  resource :subscription, only: [ :show, :destroy ] do
    post :reactivate
    get :portal
  end

  resources :teams do
    member do
      post :switch
    end
    resources :memberships, only: [ :create, :update, :destroy ]
  end
end
