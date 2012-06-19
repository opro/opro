## NOT CAPYBARA
#  ActionDispatch::IntegrationTest
#  http://guides.rubyonrails.org/testing.html#integration-testing
#  used so we can test POST actions ^_^

require 'test_helper'

class RefreshTokenTest < ActionDispatch::IntegrationTest
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

  test "clients get a valid refresh token" do
    params = {:client_id      => @client_app.client_id ,
              :client_secret  => @client_app.client_secret,
              :code           => @auth_grant.code}
    as_user(@user).post oauth_token_path(params)
    json_hash = JSON.parse(response.body)
    assert_equal json_hash['expires_in'], @auth_grant.expires_in
  end

  test "exchange a refresh_token for an access_token" do
    params = {:client_id      => @client_app.client_id ,
              :client_secret  => @client_app.client_secret,
              :refresh_token  => @auth_grant.refresh_token}

    Timecop.travel(2.days.from_now)

    as_user(@user).post oauth_token_path(params)

    json_hash = JSON.parse(response.body)
    refute_equal json_hash['access_token'],   @auth_grant.access_token
    refute_equal json_hash['refresh_token'],  @auth_grant.refresh_token
    refute_equal json_hash['expires_in'],     @auth_grant.expires_in


    auth_grant = Opro::Oauth::AuthGrant.find(@auth_grant.id)
    assert_equal json_hash['access_token'],   auth_grant.access_token
    assert_equal json_hash['refresh_token'],  auth_grant.refresh_token
    assert_equal json_hash['expires_in'],     auth_grant.expires_in
  end

end
