require 'test_helper'

class CapybaraRefreshTokenTest < ActiveSupport::IntegrationCase

  setup do
    Timecop.freeze(Time.now)
    Opro.setup do |config|
      config.require_refresh_within = 1.month
    end

    @user         = create_user
    @auth_grant   = create_auth_grant_for_user(@user)
    @client_app   = @auth_grant.application
  end

  teardown do
    Timecop.return # "turn off" Timecop
  end

  test "clients with an expired token do not get logged in" do
    user         = create_user
    auth_grant   = create_auth_grant_for_user(user)
    access_token = auth_grant.access_token

    Timecop.travel(5.months.from_now)
    visit "/?access_token=#{access_token}"

    assert has_content?('NO logged in users')
    assert auth_grant.expired?
  end

end
