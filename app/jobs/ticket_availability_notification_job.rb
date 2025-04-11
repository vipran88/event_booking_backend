class TicketAvailabilityNotificationJob < ApplicationJob
  queue_as :default

  # Job to notify event organizers when ticket availability is running low
  # This job is designed to be scheduled to run periodically
  def perform
    # Find tickets with low availability (less than 10% of original quantity)
    Ticket.all.each do |ticket|
      # Skip if ticket is already sold out
      next if ticket.quantity_available == 0
      
      # Calculate the percentage of tickets remaining
      original_quantity = ticket.quantity_available + ticket.bookings.sum(:quantity)
      remaining_percentage = (ticket.quantity_available.to_f / original_quantity) * 100
      
      # If less than 10% of tickets remain, notify the event organizer
      if remaining_percentage < 10
        event = ticket.event
        event_organizer = event.event_organizer
        
        # Send low ticket availability notification
        EventOrganizerMailer.low_ticket_availability(event_organizer, event, ticket).deliver_now
      end
    end
  end
end
