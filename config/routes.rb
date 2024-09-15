Rails.application.routes.draw do
  get 'dashboard/index'
  root 'home#index'
  post 'data_generate', to: 'dashboard#data_generate'
  devise_for :users
  # ... other routes ...
end