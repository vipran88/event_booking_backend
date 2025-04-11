class BookingMailer < ApplicationMailer
  default from: 'notifications@eventbooking.com'

  # Send a booking confirmation email
  def confirmation_email(booking)
    @booking = booking
    @customer = booking.customer
    @event = booking.ticket.event
    @ticket = booking.ticket
    
    mail(
      to: @customer.user.email,
      subject: "Booking Confirmation: #{@event.title}"
    )
  end

  # Send a booking cancellation email
  def cancellation_email(booking)
    @booking = booking
    @customer = booking.customer
    @event = booking.ticket.event
    @ticket = booking.ticket
    
    mail(
      to: @customer.user.email,
      subject: "Booking Cancellation: #{@event.title}"
    )
  end
end
