require 'test_helper'

class Opro::Oauth::TestsControllerTest < ActionController::TestCase
  tests Opro::Oauth::TestsController
  include Devise::Test::ControllerHelpers

  setup do
    @user         = create_user
    @auth_grant   = create_auth_grant_for_user(@user)
  end

  test "access_token with write ability can :POST" do
    permissions = {'write' => true}
    @auth_grant.update_permissions(permissions)

    post :create, :params => { :access_token => @auth_grant.access_token }, :format => :json
    assert_response :success
  end


  test "access_token with NO write ability can NOT POST" do
    permissions = {:write => false}
    @auth_grant.update_permissions(permissions)
    post :create, :params => { :access_token => @auth_grant.access_token }, :format => :json
    assert_response 401
  end
end
