ActiveModelSerializers.config.tap do |config|
  # Use the JSON adapter for a simpler API response format
  config.adapter = :json
  
  # Set the key transform to camel_lower for JavaScript/TypeScript clients
  # This converts snake_case attribute names to camelCase in the JSON output
  config.key_transform = :camel_lower
  
  # Include the root key in JSON
  config.include_root_in_json = false
end
