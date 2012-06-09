require 'test_helper'

class AuthControllerTest < ActiveSupport::IntegrationCase

  test 'auth entry point should not be accessable to logged OUT users' do
    visit oauth_new_path
    assert_equal '/users/sign_in', current_path
  end

  test 'auth entry point is accessable to logged IN users' do
    app           = create_client_app
    user          = create_user
    redirect_uri  = '/'

    as_user(user).visit oauth_new_path(:client_id => app.client_id, :redirect_uri => redirect_uri)

    assert_equal '/oauth/new', current_path

    click_button 'oauthAuthorize'
    assert_equal '/', current_path
    assert Oauth::AccessGrant.where(:user_id => user.id, :application_id => app.id).present?
  end
end
