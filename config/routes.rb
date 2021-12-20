Rails.application.routes.draw do
  resource :temp_reading, only: [:index]
  resource :temp_monitor, only: [:index, :show, :edit, :update]

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root "home#show"
end
