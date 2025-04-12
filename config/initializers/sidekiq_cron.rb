# config/initializers/sidekiq_cron.rb
# Schedule background jobs to run at specific intervals

# Only configure Sidekiq-cron if it's being used and not explicitly skipped
if defined?(Sidekiq::Cron) && ENV['SKIP_SIDEKIQ'] != 'true'
  begin
    # Load the schedule from a YAML file if it exists
    schedule_file = Rails.root.join('config', 'schedule.yml')
    
    if File.exist?(schedule_file)
      # Load jobs from the schedule.yml file
      schedule_hash = YAML.load_file(schedule_file)
      
      # Check if the loaded hash is valid
      if schedule_hash.is_a?(Hash)
        # Load the job schedule
        Sidekiq::Cron::Job.load_from_hash(schedule_hash)
        Rails.logger.info "Loaded Sidekiq-cron schedule from #{schedule_file}"
        
        # Log the loaded jobs
        Sidekiq::Cron::Job.all.each do |job|
          Rails.logger.info "Scheduled job: #{job.name}, cron: #{job.cron}, next run: #{job.next_time}"
        end
      else
        Rails.logger.error "Invalid schedule.yml format. Expected a hash, got #{schedule_hash.class}"
      end
    else
      Rails.logger.warn "No schedule.yml file found at #{schedule_file}. Creating default schedule."
      
      # Define jobs directly in the initializer if no schedule file exists
      default_jobs = {
        'event_reminder_job' => {
          'cron' => '0 8 * * *', # At 8:00 AM every day
          'class' => 'EventReminderJob',
          'queue' => 'default',
          'description' => 'Sends reminders for events happening in the next 24 hours'
        },
        'ticket_availability_notification_job' => {
          'cron' => '0 */6 * * *', # Every 6 hours
          'class' => 'TicketAvailabilityNotificationJob',
          'queue' => 'default',
          'description' => 'Notifies event organizers when ticket availability is running low'
        }
      }
      
      # Load the default jobs
      Sidekiq::Cron::Job.load_from_hash(default_jobs)
      Rails.logger.info "Created default Sidekiq-cron schedule"
    end
  rescue => e
    Rails.logger.error "Sidekiq-cron configuration failed: #{e.message}\n#{e.backtrace.join('\n')}"
  end
end
