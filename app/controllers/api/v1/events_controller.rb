class Api::V1::EventsController < Api::V1::BaseController
  before_action :set_event, only: [:show, :update, :destroy]
  
  # Load and authorize resource using CanCanCan
  load_and_authorize_resource except: [:create]
  
  # GET /api/v1/events
  def index
    @events = Event.all
    render json: @events, each_serializer: EventSerializer, include: params[:include]
  end
  
  # GET /api/v1/events/:id
  def show
    render json: @event, serializer: EventSerializer, include: params[:include]
  end
  
  # POST /api/v1/events
  def create
    # Create event associated with the current event organizer
    @event = Event.new(event_params)
    @event.event_organizer = current_user.event_organizer if current_user&.event_organizer?
    
    # Authorize the new event
    authorize! :create, @event
    
    if @event.save
      render json: @event, serializer: EventSerializer, status: :created
    else
      render_error(@event.errors.full_messages.join(', '))
    end
  end
  
  # PATCH/PUT /api/v1/events/:id
  def update
    if @event.update(event_params)
      render json: @event, serializer: EventSerializer
    else
      render_error(@event.errors.full_messages.join(', '))
    end
  end
  
  # DELETE /api/v1/events/:id
  def destroy
    @event.destroy
    head :no_content
  end
  
  private
  
  def set_event
    @event = Event.find_by(id: params[:id])
    render_not_found('event') unless @event
  end
  
  # Handle authorization errors
  rescue_from CanCan::AccessDenied do |exception|
    render_error(exception.message, :forbidden)
  end
  
  def event_params
    params.require(:event).permit(:title, :description, :venue, :event_date, :capacity, :event_organizer_id)
  end
end
