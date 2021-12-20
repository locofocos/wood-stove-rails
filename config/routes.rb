Rails.application.routes.draw do
  get 'temp_monitors/index'
  get 'temp_monitors/show'
  get 'temp_monitors/edit'
  get 'temp_monitors/update'
  get 'temp_readings/index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root "home#show"
end
