module Api
  module V1
    class JobsController < BaseController
      before_action :authenticate_user!
      
      # POST /api/v1/jobs/test_booking_notification
      # Test endpoint to trigger the BookingNotificationJob
      def test_booking_notification
        booking_id = params[:booking_id]
        notification_type = params[:notification_type] || 'confirmation'
        
        # Validate parameters
        unless booking_id.present? && Booking.exists?(booking_id)
          return render json: { error: 'Invalid booking ID' }, status: :bad_request
        end
        
        unless ['confirmation', 'cancellation'].include?(notification_type)
          return render json: { error: 'Invalid notification type' }, status: :bad_request
        end
        
        # Enqueue the job
        job_id = BookingNotificationJob.perform_async(notification_type, booking_id)
        
        if job_id
          render json: { 
            message: "BookingNotificationJob enqueued successfully", 
            job_id: job_id,
            booking_id: booking_id,
            notification_type: notification_type
          }, status: :ok
        else
          render json: { error: 'Failed to enqueue job' }, status: :internal_server_error
        end
      end
      
      # POST /api/v1/jobs/test_event_reminder
      # Test endpoint to trigger the EventReminderJob
      def test_event_reminder
        # Enqueue the job
        job_id = EventReminderJob.perform_async
        
        if job_id
          render json: { 
            message: "EventReminderJob enqueued successfully", 
            job_id: job_id
          }, status: :ok
        else
          render json: { error: 'Failed to enqueue job' }, status: :internal_server_error
        end
      end
      
      # POST /api/v1/jobs/test_ticket_availability
      # Test endpoint to trigger the TicketAvailabilityNotificationJob
      def test_ticket_availability
        # Enqueue the job
        job_id = TicketAvailabilityNotificationJob.perform_async
        
        if job_id
          render json: { 
            message: "TicketAvailabilityNotificationJob enqueued successfully", 
            job_id: job_id
          }, status: :ok
        else
          render json: { error: 'Failed to enqueue job' }, status: :internal_server_error
        end
      end
    end
  end
end
