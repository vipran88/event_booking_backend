class TicketAvailabilityNotificationJob
  include Sidekiq::Job
  sidekiq_options queue: :mailers, retry: 3

  # Job to notify event organizers when ticket availability is running low
  # This job is designed to be scheduled to run periodically
  def perform
    logger.info "Starting TicketAvailabilityNotificationJob at #{Time.now}"
    
    # Track statistics for logging
    tickets_checked = 0
    notifications_sent = 0
    
    # Find tickets with low availability (less than 10% of original quantity)
    Ticket.all.each do |ticket|
      tickets_checked += 1
      
      # Skip if ticket is already sold out
      if ticket.quantity_available == 0
        logger.info "Ticket ##{ticket.id} for event ##{ticket.event_id} is sold out"
        next
      end
      
      # Calculate the percentage of tickets remaining
      original_quantity = ticket.quantity_available + ticket.bookings.sum(:quantity)
      remaining_percentage = (ticket.quantity_available.to_f / original_quantity) * 100
      
      logger.info "Ticket ##{ticket.id} for event ##{ticket.event_id} has #{ticket.quantity_available} tickets remaining (#{remaining_percentage.round(2)}%)"
      
      # If less than 10% of tickets remain, notify the event organizer
      if remaining_percentage < 10
        event = ticket.event
        event_organizer = event.event_organizer
        
        logger.info "Sending low ticket availability notification for ticket ##{ticket.id} (#{ticket.ticket_type}) of event ##{event.id} - #{event.title}"
        
        # Send low ticket availability notification
        EventOrganizerMailer.low_ticket_availability(event_organizer, event, ticket).deliver_now
        notifications_sent += 1
      end
    end
    
    logger.info "Completed TicketAvailabilityNotificationJob: checked #{tickets_checked} tickets, sent #{notifications_sent} notifications"
  end
end
