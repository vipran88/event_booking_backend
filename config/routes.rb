Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # API Routes
  namespace :api do
    namespace :v1 do
      # Authentication routes
      post 'auth/register', to: 'auth#register'
      post 'auth/login', to: 'auth#login'
      delete 'auth/logout', to: 'auth#logout'
      
      # Event routes - full CRUD for event organizers
      resources :events
      
      # Ticket routes - full CRUD for event organizers
      resources :tickets
      
      # Booking routes - limited actions for customers
      resources :bookings, only: [:index, :show, :create, :destroy]
      
      # Nested routes for better resource organization
      resources :events do
        resources :tickets, only: [:index]
      end
      
      resources :customers do
        resources :bookings, only: [:index]
      end
    end
  end
end
