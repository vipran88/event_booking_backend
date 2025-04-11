class Api::V1::BookingsController < Api::V1::BaseController
  before_action :set_booking, only: [:show, :update, :destroy]
  
  # Load and authorize resource using CanCanCan
  load_and_authorize_resource except: [:create]
  
  # GET /api/v1/bookings
  def index
    if params[:customer_id]
      @bookings = Booking.where(customer_id: params[:customer_id])
    else
      @bookings = Booking.all
    end
    render json: @bookings, each_serializer: BookingSerializer, include: params[:include]
  end
  
  # GET /api/v1/bookings/:id
  def show
    render json: @booking, serializer: BookingSerializer, include: params[:include]
  end
  
  # POST /api/v1/bookings
  def create
    @booking = Booking.new(booking_params)
    
    # Associate booking with current customer
    @booking.customer = current_user.customer if current_user&.customer?
    
    # Authorize the booking creation
    authorize! :create, @booking
    
    # Calculate total price based on ticket price and quantity
    if @booking.ticket && @booking.quantity
      @booking.total_price = @booking.ticket.price * @booking.quantity
    end
    
    # Check if enough tickets are available
    if @booking.ticket && @booking.quantity > @booking.ticket.quantity_available
      return render_error('Not enough tickets available')
    end
    
    if @booking.save
      # Update available ticket quantity
      @booking.ticket.update(quantity_available: @booking.ticket.quantity_available - @booking.quantity)
      
      # Queue a background job to send confirmation email
      # If Sidekiq is not available, send email directly
      begin
        BookingNotificationJob.perform_later('confirmation', @booking.id)
      rescue => e
        # Fallback to direct email delivery if background job fails
        Rails.logger.warn "Background job failed, sending email directly: #{e.message}"
        BookingMailer.confirmation_email(@booking).deliver_now
      end
      
      render json: @booking, serializer: BookingSerializer, status: :created
    else
      render_error(@booking.errors.full_messages.join(', '))
    end
  end
  
  # Only allow customers to view or cancel their bookings, not update them
  # DELETE /api/v1/bookings/:id
  def destroy
    # Cancellation logic
    # - Update ticket availability
    # - Process refund if applicable
    # - Send cancellation email
    
    # Store booking ID before destroying the record
    booking_id = @booking.id
    
    # Update ticket availability
    @booking.ticket.update(quantity_available: @booking.ticket.quantity_available + @booking.quantity)
    
    # Queue cancellation email before destroying the record
    # If Sidekiq is not available, send email directly
    begin
      BookingNotificationJob.perform_later('cancellation', booking_id)
    rescue => e
      # Fallback to direct email delivery if background job fails
      Rails.logger.warn "Background job failed, sending email directly: #{e.message}"
      BookingMailer.cancellation_email(@booking).deliver_now
    end
    
    # Destroy the booking record
    @booking.destroy
    
    head :no_content
  end
  
  private
  
  def set_booking
    @booking = Booking.find_by(id: params[:id])
    render_not_found('booking') unless @booking
  end
  
  # Handle authorization errors
  rescue_from CanCan::AccessDenied do |exception|
    render_error(exception.message, :forbidden)
  end
  
  def booking_params
    params.require(:booking).permit(:customer_id, :ticket_id, :quantity)
  end
end
