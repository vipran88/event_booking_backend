# Preview all emails at http://localhost:3000/rails/mailers/event_organizer_mailer
class EventOrganizerMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/event_organizer_mailer/low_ticket_availability
  def low_ticket_availability
    EventOrganizerMailer.low_ticket_availability
  end
end
