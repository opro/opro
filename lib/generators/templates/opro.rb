Opro.setup do |config|
  ## Configure the auth_strategy or use set :login_method, :logout_method, & :authenticate_user_method
  config.auth_strategy = :devise

  ## Add or remove application permissions
  # Read permission (any request with [GET]) is turned on by default
  # Write permission (any request other than [GET]) is requestable by default
  # Custom permissions can be configured by adding them to `config.request_permissions`
  # You can then require that permission on individual actions by calling
  # `require_oauth_permissions` in the controller
  config.request_permissions = [:write]

  ## Refresh Token config
  # uncomment `config.require_refresh_within` to require refresh tokens
  # this will expire tokens within the given time duration
  # config.require_refresh_within = 1.month
end