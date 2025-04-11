class ApplicationController < ActionController::API
  include ActionController::MimeResponds
  
  # Include Devise JWT authentication
  before_action :authenticate_user!
  respond_to :json
  
  # Handle authentication errors
  rescue_from JWT::DecodeError, with: :render_unauthorized
  rescue_from JWT::ExpiredSignature, with: :render_unauthorized
  
  private
  
  def render_unauthorized
    render json: { error: 'You are not authorized to access this resource' }, status: :unauthorized
  end
  
  # Get current user based on role
  def current_resource_owner
    if current_user&.event_organizer?
      current_user.event_organizer
    elsif current_user&.customer?
      current_user.customer
    else
      nil
    end
  end
end
