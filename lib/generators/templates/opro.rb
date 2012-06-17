Opro.setup do |config|
  ## Configure the auth_strategy or use set :login_method, :logout_method, & :authenticate_user_method
  config.auth_strategy = :devise

  ## Add or remove application permissions
  # Read permission is turned on by default (any request with [GET])
  # Write permission is requestable by default (any request other than [GET])
  # Custom permissions can be configured by adding them to the request_permissions Array and configuring require_oauth_permissions in the controller
  config.request_permissions = [:write]

  ## Refresh Token config
  # uncomment `config.require_refresh_within` to require refresh tokens
  # this will expire tokens within the given time duration
  # tokens can be refreshed using the refresh toke
  # config.require_refresh_within = 1.month
end