class EventOrganizerMailer < ApplicationMailer
  default from: 'notifications@eventbooking.com'

  # Send a notification to event organizers when ticket availability is running low
  # @param event_organizer [EventOrganizer] The event organizer to notify
  # @param event [Event] The event with low ticket availability
  # @param ticket [Ticket] The ticket with low availability
  def low_ticket_availability(event_organizer, event, ticket)
    @event_organizer = event_organizer
    @event = event
    @ticket = ticket
    @remaining_count = ticket.quantity_available
    @total_count = ticket.quantity_available + ticket.bookings.sum(:quantity)
    @percentage = (@remaining_count.to_f / @total_count) * 100
    
    mail(
      to: @event_organizer.user.email,
      subject: "Low Ticket Availability Alert: #{@event.title}"
    )
  end
end
