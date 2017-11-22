## NOT CAPYBARA
#  ActionDispatch::IntegrationTest
#  http://guides.rubyonrails.org/testing.html#integration-testing
#  used so we can test POST actions ^_^

require 'test_helper'

class AuthControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user         = create_user
    @client_app   = create_client_app
    @redirect_uri = '/'
  end

  test "AUTHORIZE: previously authed user gets Authed immediately, permissions not changed" do
    auth_grant  = create_auth_grant_for_user(@user, @client_app)

    params = { :client_id     => @client_app.client_id ,
               :client_secret => @client_app.client_secret,
               :redirect_uri  => @redirect_uri }

    as_user(@user).post oauth_authorize_path(params)

    assert_equal 302, status
    follow_redirect!
    assert_equal @redirect_uri, path
  end

  # Tests against common OAuth Security issue
  # http://homakov.blogspot.com/2012/07/saferweb-most-common-oauth2.html
  # still relies on client to submit :status param
  test "oauth auth jacking is can be avoided by clients" do
    auth_grant  = create_auth_grant_for_user(@user, @client_app)
    state = SecureRandom.hex(16)
    params = { :client_id     => @client_app.client_id ,
               :client_secret => @client_app.client_secret,
               :redirect_uri  => @redirect_uri,
               :state         => state }

    as_user(@user).post oauth_authorize_path(params)

    assert response["Location"].include?("state=#{state}")

    assert_equal 302, status
    follow_redirect!

    assert_equal @redirect_uri, path
    assert_equal 200, status
  end


  test "AUTHORIZE: app cannot force permissions change for previously authed user" do
    auth_grant  = create_auth_grant_for_user(@user, @client_app)
    permissions = { 'foo' => 1 }
    assert_not_equal auth_grant.permissions, permissions

    params = { :client_id     => @client_app.client_id ,
               :client_secret => @client_app.client_secret,
               :redirect_uri  => @redirect_uri,
               :permissions   => permissions }

    as_user(@user).post oauth_authorize_path(params)

    assert_equal 302, status
    follow_redirect!
    assert_equal @redirect_uri, path
    auth_grant = Opro::Oauth::AuthGrant.find(auth_grant.id)

    refute auth_grant.permissions.has_key?(permissions.keys.first)
  end

  test "AUTHORIZE: user gets redirected to new form if not already authed" do
    params = { :client_id     => @client_app.client_id ,
               :client_secret => @client_app.client_secret,
               :redirect_uri  => @redirect_uri }

    as_user(@user).post oauth_authorize_path(params)

    assert_equal 302, status
    follow_redirect!
    assert_equal oauth_new_path, path
  end

end
