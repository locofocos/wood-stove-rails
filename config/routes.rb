Rails.application.routes.draw do
  resource :temp_readings, only: [:index]
  resource :temp_monitors, only: [:index, :show, :edit, :update]

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root "home#show"
end
