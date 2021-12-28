Rails.application.routes.draw do
  resources :settings, only: [:index, :update]
  resources :temp_readings, only: [:index]
  resources :temp_monitors

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root "home#show"
end
