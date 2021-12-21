Rails.application.routes.draw do
  resources :temp_readings, only: [:index]
  resources :temp_monitors, only: [:index, :show, :edit, :update]

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root "home#show"
end
