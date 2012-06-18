require 'test_helper'

class Oauth::TestsControllerTest < ActionController::TestCase
  tests Oauth::TestsController
  include Devise::TestHelpers

  setup do
    @user         = create_user
    @auth_grant   = create_auth_grant_for_user(@user)
  end

  test "access_token with write ability can :POST" do
    permissions = {'write' => true}
    @auth_grant.update_attributes(:permissions => permissions)

    post :create, access_token => @auth_grant.access_token, format => :json
    assert_response :success
  end


  test "access_token with NO write ability can NOT POST" do
    permissions = {:write => false}
    @auth_grant.update_attributes(:permissions => permissions)
    post :create, access_token => @auth_grant.access_token, format =>  :json
    assert_response 401
  end
end
