class BookingNotificationJob < ApplicationJob
  queue_as :default

  # Job to handle sending booking-related emails asynchronously
  # @param notification_type [String] Type of notification ('confirmation' or 'cancellation')
  # @param booking_id [Integer] ID of the booking to send notification for
  def perform(notification_type, booking_id)
    booking = Booking.find_by(id: booking_id)
    
    # Return early if booking not found
    return unless booking
    
    case notification_type
    when 'confirmation'
      # Send booking confirmation email
      BookingMailer.confirmation_email(booking).deliver_now
    when 'cancellation'
      # Send booking cancellation email
      BookingMailer.cancellation_email(booking).deliver_now
    end
  end
end
