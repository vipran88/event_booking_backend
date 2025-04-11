module Api
  module V1
    class BaseController < ApplicationController
      # Common functionality for all API controllers
      
      # Skip CSRF protection for API
      # skip_before_action :verify_authenticity_token
      
      # Error handling methods
      def render_error(message, status = :unprocessable_entity)
        render json: { error: message }, status: status
      end
      
      def render_not_found(resource = 'resource')
        render_error("The requested #{resource} could not be found", :not_found)
      end
      
      def render_unauthorized
        render_error('You are not authorized to perform this action', :unauthorized)
      end
      
      # Helper method to get the current authenticated user's profile
      def current_profile
        if current_user&.event_organizer?
          current_user.event_organizer
        elsif current_user&.customer?
          current_user.customer
        else
          nil
        end
      end
    end
  end
end
