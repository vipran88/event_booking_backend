class EventReminderJob
  include Sidekiq::Job
  sidekiq_options queue: :mailers, retry: 3

  # Job to send reminders for upcoming events
  # This job is designed to be scheduled to run daily
  def perform
    logger.info "Starting EventReminderJob at #{Time.now}"
    
    # Find events happening in the next 24 hours
    upcoming_events = Event.where(event_date: Time.now..(Time.now + 1.day))
    
    if upcoming_events.empty?
      logger.info "No upcoming events found for the next 24 hours"
      return
    end
    
    logger.info "Found #{upcoming_events.count} upcoming events in the next 24 hours"
    
    upcoming_events.each do |event|
      # Find all bookings for this event
      bookings = Booking.joins(ticket: :event).where(tickets: { event_id: event.id })
      
      if bookings.empty?
        logger.info "No bookings found for event ##{event.id} - #{event.title}"
        next
      end
      
      logger.info "Sending #{bookings.count} reminder emails for event ##{event.id} - #{event.title}"
      
      # Send reminder to each customer who has booked
      bookings.each do |booking|
        # Send reminder email
        EventMailer.reminder_email(booking).deliver_now
        logger.info "Sent reminder email for booking ##{booking.id} to customer ##{booking.customer_id}"
      end
    end
    
    logger.info "Completed EventReminderJob at #{Time.now}"
  end
end
