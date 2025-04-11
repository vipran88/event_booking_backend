# Preview all emails at http://localhost:3000/rails/mailers/event_mailer
class EventMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/event_mailer/reminder_email
  def reminder_email
    EventMailer.reminder_email
  end
end
