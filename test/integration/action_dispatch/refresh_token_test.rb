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

    post oauth_token_path(params)
    json_hash = JSON.parse(response.body)
    assert_equal json_hash['expires_in'], @auth_grant.expires_in
  end

  test "exchange a refresh_token for an access_token" do
    params = {:client_id      => @client_app.client_id ,
              :client_secret  => @client_app.client_secret,
              :refresh_token  => @auth_grant.refresh_token}

    Timecop.travel(2.days.from_now)

    post oauth_token_path(params)

    json_hash = JSON.parse(response.body)
    refute_equal json_hash['access_token'],   @auth_grant.access_token
    refute_equal json_hash['refresh_token'],  @auth_grant.refresh_token
    refute_equal json_hash['expires_in'],     @auth_grant.expires_in


    auth_grant = Opro::Oauth::AuthGrant.find(@auth_grant.id)
    assert_equal json_hash['access_token'],   auth_grant.access_token
    assert_equal json_hash['refresh_token'],  auth_grant.refresh_token
    assert_equal json_hash['expires_in'],     auth_grant.expires_in
  end

  test "after expires in period, access_token is no longer valid" do
    Timecop.freeze(@client_app.created_at)
    params = {:client_id      => @client_app.client_id ,
              :client_secret  => @client_app.client_secret,
              :code           => @auth_grant.code}

    post oauth_token_path(params)
    json_hash    = JSON.parse(response.body)
    expires_in   = json_hash['expires_in']
    access_token = json_hash['access_token']

    # should be valid
    Timecop.travel(expires_in.seconds.from_now - 1.second)
    get oauth_test_path(:show_me_the_money, access_token: access_token)
    assert_equal 200, response.status

    # should not be valid
    Timecop.travel(expires_in.seconds.from_now + 1.second)
    get oauth_test_path(:show_me_the_money, access_token: access_token)
    refute_equal 200, response.status


    params = {:client_id      => @client_app.client_id ,
              :client_secret  => @client_app.client_secret,
              :refresh_token  => @auth_grant.reload.refresh_token}

    # make it valid again by refreshing the token
    post oauth_token_path(params)
    access_token = JSON.parse(response.body)['access_token']
    get oauth_test_path(:show_me_the_money, access_token: access_token)
    assert_equal 200, response.status
  end

end
