class EventReminderJob < ApplicationJob
  queue_as :default

  # Job to send reminders for upcoming events
  # This job is designed to be scheduled to run daily
  def perform
    # Find events happening in the next 24 hours
    upcoming_events = Event.where(event_date: Time.now..(Time.now + 1.day))
    
    upcoming_events.each do |event|
      # Find all bookings for this event
      bookings = Booking.joins(ticket: :event).where(tickets: { event_id: event.id })
      
      # Send reminder to each customer who has booked
      bookings.each do |booking|
        # Send reminder email
        EventMailer.reminder_email(booking).deliver_now
      end
    end
  end
end
