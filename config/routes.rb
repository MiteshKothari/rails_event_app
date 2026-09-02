Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  root "events#index"
  resources :events, only: [:index] do
    resources :votes, only: [:create]
  end
  resource :session, only: [:new, :create, :destroy]

  # Defines the root path route ("/")
  # root "posts#index"
end
