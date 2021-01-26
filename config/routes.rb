Rails.application.routes.draw do
  namespace :admin do
    resources :offers, except: [:show]
  end

  resources :offers, only: [:index]
end
