Rails.application.routes.draw do
  namespace :admin do
    resources :offers, except: [:show]
  end

  resources :offers, only: [:index]

  root to: 'home#index'
end
