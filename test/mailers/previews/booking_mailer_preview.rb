# Preview all emails at http://localhost:3000/rails/mailers/booking_mailer
class BookingMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/booking_mailer/confirmation_email
  def confirmation_email
    BookingMailer.confirmation_email
  end

  # Preview this email at http://localhost:3000/rails/mailers/booking_mailer/cancellation_email
  def cancellation_email
    BookingMailer.cancellation_email
  end
end
