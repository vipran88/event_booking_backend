# Configure Sidekiq for background job processing
if defined?(Sidekiq) && ENV['SKIP_SIDEKIQ'] != 'true'
  begin
    # Server configuration (used by Sidekiq workers)
    Sidekiq.configure_server do |config|
      # Set Redis connection
      config.redis = { 
        url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0'),
        ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE } # For secure Redis connections
      }
      
      # Set concurrency (adjust based on your server resources)
      config.concurrency = ENV.fetch('SIDEKIQ_CONCURRENCY', 5).to_i
      
      # Set up error handling
      config.error_handlers << proc { |ex, ctx_hash| 
        Rails.logger.error "Sidekiq error: #{ex.message}\nContext: #{ctx_hash}\nBacktrace: #{ex.backtrace.join('\n')}"
      }
      
      # Set up death handler for jobs that exceed retry attempts
      config.death_handlers << proc { |job, ex| 
        Rails.logger.error "Sidekiq job #{job['class']} failed permanently with: #{ex.message}"
      }
    end

    # Client configuration (used by Rails application to enqueue jobs)
    Sidekiq.configure_client do |config|
      # Set Redis connection
      config.redis = { 
        url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0'),
        ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE } # For secure Redis connections
      }
      
      # Set client pool size
      config.client_middleware do |chain|
        chain.add Sidekiq::ClientMiddleware::UniqueJobs if defined?(Sidekiq::ClientMiddleware::UniqueJobs)
      end
    end
    
    # Log successful configuration
    Rails.logger.info "Sidekiq configured successfully with Redis at #{ENV.fetch('REDIS_URL', 'redis://localhost:6379/0')}"
    
  rescue Redis::CannotConnectError => e
    Rails.logger.error "Warning: Redis connection failed. Sidekiq will not be available: #{e.message}"
  rescue => e
    Rails.logger.error "Error configuring Sidekiq: #{e.message}"
  end
end
