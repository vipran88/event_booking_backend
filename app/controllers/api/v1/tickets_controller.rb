class Api::V1::TicketsController < Api::V1::BaseController
  before_action :set_ticket, only: [:show, :update, :destroy]
  
  # Load and authorize resource using CanCanCan
  load_and_authorize_resource except: [:create]
  
  # GET /api/v1/tickets
  def index
    if params[:event_id]
      @tickets = Ticket.where(event_id: params[:event_id])
    else
      @tickets = Ticket.all
    end
    render json: @tickets, each_serializer: TicketSerializer, include: params[:include]
  end
  
  # GET /api/v1/tickets/:id
  def show
    render json: @ticket, serializer: TicketSerializer, include: params[:include]
  end
  
  # POST /api/v1/tickets
  def create
    @ticket = Ticket.new(ticket_params)
    
    # Ensure the event belongs to the current event organizer
    event = Event.find_by(id: ticket_params[:event_id])
    authorize! :manage, event if event.present?
    
    if @ticket.save
      render json: @ticket, serializer: TicketSerializer, status: :created
    else
      render_error(@ticket.errors.full_messages.join(', '))
    end
  end
  
  # PATCH/PUT /api/v1/tickets/:id
  def update
    if @ticket.update(ticket_params)
      render json: @ticket, serializer: TicketSerializer
    else
      render_error(@ticket.errors.full_messages.join(', '))
    end
  end
  
  # DELETE /api/v1/tickets/:id
  def destroy
    @ticket.destroy
    head :no_content
  end
  
  private
  
  def set_ticket
    @ticket = Ticket.find_by(id: params[:id])
    render_not_found('ticket') unless @ticket
  end
  
  # Handle authorization errors
  rescue_from CanCan::AccessDenied do |exception|
    render_error(exception.message, :forbidden)
  end
  
  def ticket_params
    params.require(:ticket).permit(:event_id, :ticket_type, :price, :quantity_available)
  end
end
