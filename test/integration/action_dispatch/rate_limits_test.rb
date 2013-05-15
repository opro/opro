## NOT CAPYBARA
#  ActionDispatch::IntegrationTest
#  http://guides.rubyonrails.org/testing.html#integration-testing
#  used so we can test POST actions ^_^

require 'test_helper'

class RateLimitTest < ActionDispatch::IntegrationTest

  setup do
    @user         = create_user
    @auth_grant   = create_auth_grant_for_user(@user)
    @client_app   = @auth_grant.application
    @params       = {:client_id      => @client_app.client_id ,
                     :client_secret  => @client_app.client_secret,
                     :access_token   => @auth_grant.access_token}
    @auth_grant.update_permissions(:write => true)
  end

  test "A rate limited app does not get a valid user" do
    Opro::Oauth::TestsController.any_instance.stubs(:oauth_client_over_rate_limit?).returns(true)

    post oauth_tests_path(@params)

    assert_equal 401, status
  end

    test "A NON rate limited app does get a valid user" do
    Opro::Oauth::TestsController.any_instance.expects(:oauth_client_record_access!).at_least_once
    Opro::Oauth::TestsController.any_instance.stubs(:oauth_client_over_rate_limit?).returns(false)

    post oauth_tests_path(@params)

    assert_equal 200, status
  end

end
