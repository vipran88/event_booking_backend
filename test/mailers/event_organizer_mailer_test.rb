require "test_helper"

class EventOrganizerMailerTest < ActionMailer::TestCase
  test "low_ticket_availability" do
    mail = EventOrganizerMailer.low_ticket_availability
    assert_equal "Low ticket availability", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end
end
