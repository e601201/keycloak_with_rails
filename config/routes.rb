Rails.application.routes.draw do
  root 'static_pages#top'
  resources :users
  get '/auth/:provider/callback', to: 'sessions#create'
  get '/top', to: 'static_pages#top'
  get '/user', to: 'static_pages#user'
  delete '/logout', to: 'sessions#delete'
end
