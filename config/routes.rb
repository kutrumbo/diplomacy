Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'games#index'

  resources :sessions, only: [:new, :create, :destroy]
  resources :users, only: [:new, :create]
  resources :games, only: [:index, :show] do
    put 'orders', to: 'orders#update'
    resources :turns, only: [] do
      get 'orders', to: 'orders#resolutions'
    end
  end
  get 'map', to: 'games#map'

  get 'signup', to: 'users#new', as: 'signup'
  get 'login', to: 'sessions#new', as: 'login'
  get 'logout', to: 'sessions#destroy', as: 'logout'
end
