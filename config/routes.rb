Rails.application.routes.draw do
  devise_for :users, skip: [:sessions, :registrations, :passwords]

  namespace :api, defaults: { format: :json } do
    namespace :v1 do

      post 'login', to: 'sessions#create'
      delete 'logout', to: 'sessions#destroy'

      resources :affordability_assessments, only: [:create]
    end
  end
end
