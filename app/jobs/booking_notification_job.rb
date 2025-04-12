class BookingNotificationJob
  include Sidekiq::Job
  sidekiq_options queue: :mailers, retry: 5

  # Job to handle sending booking-related emails asynchronously
  # @param notification_type [String] Type of notification ('confirmation' or 'cancellation')
  # @param booking_id [Integer] ID of the booking to send notification for
  def perform(notification_type, booking_id)
    booking = Booking.find_by(id: booking_id)
    
    # Return early if booking not found
    return unless booking
    
    # Log job execution
    logger.info "Processing #{notification_type} notification for booking ##{booking_id}"
    
    case notification_type
    when 'confirmation'
      # Send booking confirmation email
      BookingMailer.confirmation_email(booking).deliver_now
      logger.info "Sent confirmation email for booking ##{booking_id}"
    when 'cancellation'
      # Send booking cancellation email
      BookingMailer.cancellation_email(booking).deliver_now
      logger.info "Sent cancellation email for booking ##{booking_id}"
    else
      logger.error "Unknown notification type: #{notification_type}"
    end
  end
end
