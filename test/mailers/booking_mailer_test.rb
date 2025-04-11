require "test_helper"

class BookingMailerTest < ActionMailer::TestCase
  test "confirmation_email" do
    mail = BookingMailer.confirmation_email
    assert_equal "Confirmation email", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end

  test "cancellation_email" do
    mail = BookingMailer.cancellation_email
    assert_equal "Cancellation email", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end
end
