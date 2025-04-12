module ApiHelpers
  def json_response
    JSON.parse(response.body)
  end
  
  def auth_headers(user)
    token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil)
    {
      'Authorization' => "Bearer #{token}",
      'Accept' => 'application/json',
      'Content-Type' => 'application/json'
    }
  end
end

RSpec.configure do |config|
  config.include ApiHelpers, type: :request
end
