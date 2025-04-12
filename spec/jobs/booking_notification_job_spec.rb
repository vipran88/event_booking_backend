require 'rails_helper'

RSpec.describe BookingNotificationJob, type: :job do
  # Use Sidekiq's testing functionality
  include Sidekiq::Testing
  Sidekiq::Testing.fake! # Don't actually enqueue jobs

  let(:customer) { create(:customer) }
  let(:event) { create(:event) }
  let(:ticket) { create(:ticket, event: event) }
  let(:booking) { create(:booking, customer: customer, ticket: ticket) }
  let(:logger) { instance_double(Logger) }

  before do
    # Mock the logger to prevent actual logging during tests
    allow_any_instance_of(BookingNotificationJob).to receive(:logger).and_return(logger)
    allow(logger).to receive(:info)
    allow(logger).to receive(:error)
  end

  describe "#perform" do
    context "with confirmation notification type" do
      it "sends a confirmation email" do
        expect(BookingMailer).to receive(:confirmation_email).with(booking).and_return(double(deliver_now: true))
        expect(logger).to receive(:info).with(/Processing confirmation notification for booking ##{booking.id}/)
        expect(logger).to receive(:info).with(/Sent confirmation email for booking ##{booking.id}/)
        
        # Use perform_inline to execute the job immediately
        BookingNotificationJob.new.perform('confirmation', booking.id)
      end
      
      it "can be enqueued" do
        expect {
          BookingNotificationJob.perform_async('confirmation', booking.id)
        }.to change(BookingNotificationJob.jobs, :size).by(1)
      end
    end

    context "with cancellation notification type" do
      it "sends a cancellation email" do
        expect(BookingMailer).to receive(:cancellation_email).with(booking).and_return(double(deliver_now: true))
        expect(logger).to receive(:info).with(/Processing cancellation notification for booking ##{booking.id}/)
        expect(logger).to receive(:info).with(/Sent cancellation email for booking ##{booking.id}/)
        
        BookingNotificationJob.new.perform('cancellation', booking.id)
      end
    end

    context "with invalid notification type" do
      it "logs an error" do
        expect(logger).to receive(:error).with(/Unknown notification type: invalid_type/)
        BookingNotificationJob.new.perform('invalid_type', booking.id)
      end
    end

    context "with non-existent booking" do
      it "returns early and doesn't send an email" do
        expect(BookingMailer).not_to receive(:confirmation_email)
        expect(BookingMailer).not_to receive(:cancellation_email)
        
        BookingNotificationJob.new.perform('confirmation', -1)
      end
    end
  end
end
