require "rails_helper"

RSpec.describe BookingMailer, type: :mailer do
  let(:customer) { create(:customer, name: "John Doe", email: "john@example.com") }
  let(:event) { create(:event, title: "Summer Concert") }
  let(:ticket) { create(:ticket, event: event, ticket_type: "VIP", price: 100.0) }
  let(:booking) { create(:booking, customer: customer, ticket: ticket, quantity: 2, total_price: 200.0) }

  describe "confirmation_email" do
    let(:mail) { BookingMailer.confirmation_email(booking) }

    it "renders the headers" do
      expect(mail.subject).to eq("Booking Confirmation: Summer Concert")
      expect(mail.to).to eq(["john@example.com"])
      expect(mail.from).to eq(["notifications@eventbooking.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match(/Thank you for your booking/)
      expect(mail.body.encoded).to match(/Summer Concert/)
      expect(mail.body.encoded).to match(/VIP/)
      expect(mail.body.encoded).to match(/2 tickets/)
      expect(mail.body.encoded).to match(/200.0/)
    end
  end

  describe "cancellation_email" do
    let(:mail) { BookingMailer.cancellation_email(booking) }

    it "renders the headers" do
      expect(mail.subject).to eq("Booking Cancellation: Summer Concert")
      expect(mail.to).to eq(["john@example.com"])
      expect(mail.from).to eq(["notifications@eventbooking.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match(/Your booking has been cancelled/)
      expect(mail.body.encoded).to match(/Summer Concert/)
      expect(mail.body.encoded).to match(/VIP/)
      expect(mail.body.encoded).to match(/2 tickets/)
      expect(mail.body.encoded).to match(/200.0/)
    end
  end
end
