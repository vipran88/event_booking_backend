class EventMailer < ApplicationMailer
  default from: 'notifications@eventbooking.com'

  # Send a reminder email for an upcoming event
  # @param booking [Booking] The booking to send a reminder for
  def reminder_email(booking)
    @booking = booking
    @customer = booking.customer
    @event = booking.ticket.event
    @ticket = booking.ticket
    
    mail(
      to: @customer.user.email,
      subject: "Reminder: #{@event.title} is happening soon!"
    )
  end
end
