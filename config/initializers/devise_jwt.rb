Devise.setup do |config|
  # JWT Configuration for Devise
  config.jwt do |jwt|
    # Secret key to use for JWT encryption
    jwt.secret = Rails.application.credentials.secret_key_base
    
    # The expiration time for JWT tokens (default: 1 day)
    jwt.expiration_time = 1.day.to_i
    
    # Request formats that will trigger JWT authentication
    jwt.dispatch_requests = [
      ['POST', %r{^/api/v1/auth/login$}],
      ['POST', %r{^/api/v1/auth/register$}]
    ]
    
    # Request formats that will trigger JWT revocation
    jwt.revocation_requests = [
      ['DELETE', %r{^/api/v1/auth/logout$}]
    ]
    
    # The algorithm used to sign the token
    jwt.algorithm = 'HS256'
  end
end
