Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :affordability_assessments, only: [:create]
    end
  end
end
