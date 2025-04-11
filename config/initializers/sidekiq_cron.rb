# config/initializers/sidekiq_cron.rb
# Schedule background jobs to run at specific intervals

# Only configure Sidekiq-cron if it's being used and not explicitly skipped
if defined?(Sidekiq::Cron) && ENV['SKIP_SIDEKIQ'] != 'true'
  begin
    # Load the schedule from a YAML file if it exists
    schedule_file = Rails.root.join('config', 'schedule.yml')
    
    if File.exist?(schedule_file)
      Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
    else
      # Define jobs directly in the initializer if no schedule file exists
      
      # Event reminder job - runs daily at 8:00 AM
      Sidekiq::Cron::Job.create(
        name: 'Event reminder - daily at 8:00 AM',
        cron: '0 8 * * *', # At 8:00 AM every day
        class: 'EventReminderJob',
        queue: 'default'
      )
      
      # Ticket availability notification job - runs every 6 hours
      Sidekiq::Cron::Job.create(
        name: 'Ticket availability notification - every 6 hours',
        cron: '0 */6 * * *', # Every 6 hours
        class: 'TicketAvailabilityNotificationJob',
        queue: 'default'
      )
    end
  rescue => e
    puts "Warning: Sidekiq-cron configuration failed: #{e.message}"
  end
end
