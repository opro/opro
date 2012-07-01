Opro.setup do |config|
  ## Configure the auth_strategy or use set :login_method, :logout_method, & :authenticate_user_method
  config.auth_strategy = :devise

  ## Add or Remove Application Permissions
  # Read permission (any request with [GET]) is turned on by default
  # Write permission (any request other than [GET]) is requestable by default
  # Custom permissions can be configured by adding them to `config.request_permissions`
  # You can then require that permission on individual actions by calling
  # `require_oauth_permissions` in the controller
  config.request_permissions = [:write]

  ## Refresh Token Config
  # uncomment `config.require_refresh_within` to require refresh tokens
  # this will expire tokens within the given time duration, having it enabled
  # is more secure, but harder to use.
  # config.require_refresh_within = 1.month

  ## Allow Password Exchange
  # You can allow client applications to exchange a user's credentials
  # password, etc. for an access token.
  # Caution: This bypasses the traditional OAuth flow
  # as a result users cannot opt out of client permissions, all permissions are granted
  config.password_exchange_enabled = true

end