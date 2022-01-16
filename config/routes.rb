Rails.application.routes.draw do
  resources :settings, only: [:index, :update]
  resources :temp_readings, only: [:index]
  resources :temp_monitors
  resources :confirmed_readings, only: [:new, :create]
  resources :relays, only: [:new, :create]

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root "temp_readings#index"
end
