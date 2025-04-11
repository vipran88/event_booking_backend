# Only configure Sidekiq if it's being used
if defined?(Sidekiq) && ENV['SKIP_SIDEKIQ'] != 'true'
  begin
    Sidekiq.configure_server do |config|
      config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0') }
    end

    Sidekiq.configure_client do |config|
      config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0') }
    end
  rescue Redis::CannotConnectError => e
    puts "Warning: Redis connection failed. Sidekiq will not be available: #{e.message}"
  end
end
