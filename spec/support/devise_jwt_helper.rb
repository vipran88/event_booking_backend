module DeviseJwtHelper
  def sign_in(user)
    # Generate JWT token for the user
    token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil)
    
    # Add Authorization header to the request
    @request.headers['Authorization'] = "Bearer #{token}"
  end
end

RSpec.configure do |config|
  config.include DeviseJwtHelper, type: :request
end
