Rails.application.routes.draw do
  namespace :admin do
    resources :offers, except: [:show]
  end
end
