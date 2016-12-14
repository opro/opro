module Opro::Controllers::Concerns::RateLimits
  extend ActiveSupport::Concern

  included do
    before_action :oauth_record_rate_limit!,  :if => :valid_oauth?
    before_action :oauth_fail_request!,       :if => :oauth_client_over_rate_limit?
  end

  def oauth_client_record_access!(client_id, params)
    # implement your access counting mechanism here
  end

  def oauth_client_rate_limited?(client_id, params)
    # implement your rate limiting algorithm here
  end


  # override to implement custom rate limits
  def oauth_client_over_rate_limit?
    return oauth_client_rate_limited?(oauth_client_app.id, params) unless oauth_client_app.blank?
    false
  end

  def oauth_record_rate_limit!
    return false if oauth_client_app.blank?
    oauth_client_record_access!(oauth_client_app.id, params)
  end

  def oauth_client_under_rate_limit?
    !oauth_client_over_rate_limit?
  end

end
