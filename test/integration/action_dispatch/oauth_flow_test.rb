## NOT CAPYBARA
#  ActionDispatch::IntegrationTest
#  http://guides.rubyonrails.org/testing.html#integration-testing
#  used so we can test POST actions ^_^

require 'test_helper'

class OauthTokenTest < ActionDispatch::IntegrationTest
  setup do
    @user         = create_user
  end


  test "exchange a code for a token" do
    user         = create_user
    auth_grant   = create_auth_grant_for_user(user)
    client       = auth_grant.application
    params = {:code           => auth_grant.code,
              :client_id      => client.client_id,
              :client_secret  => client.client_secret}


    as_user(@user).post oauth_token_path(params)

    json_hash = JSON.parse(response.body)
    assert json_hash["access_token"]
    assert json_hash["access_token"], auth_grant.access_token

    assert json_hash["refresh_token"]
    assert json_hash["refresh_token"], auth_grant.refresh_token
  end

end

