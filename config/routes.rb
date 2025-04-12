Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  
  # Mount Sidekiq web UI with authentication
  authenticate :user, lambda { |u| u.role == 'event_organizer' } do
    require 'sidekiq/web'
    require 'sidekiq/cron/web'
    mount Sidekiq::Web => '/sidekiq'
  end

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
      
      # Background job test routes
      post 'jobs/test_booking_notification', to: 'jobs#test_booking_notification'
      post 'jobs/test_event_reminder', to: 'jobs#test_event_reminder'
      post 'jobs/test_ticket_availability', to: 'jobs#test_ticket_availability'
    end
  end
end
