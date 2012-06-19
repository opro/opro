require 'test_helper'

class CapybaraAuthControllerTest < ActiveSupport::IntegrationCase

  setup do
    @app           = create_client_app
    @user          = create_user
    @redirect_uri  = '/'
  end

  test 'auth entry point should not be accessable to logged OUT users' do
    visit oauth_new_path(:client_id => @app.client_id, :redirect_uri => '/')
    assert_equal '/users/sign_in', current_path
  end

  test 'auth entry point is accessible to logged IN users' do
    as_user(@user) do
      visit oauth_new_path(:client_id => @app.client_id, :redirect_uri => @redirect_uri)

      assert_equal '/oauth/new', current_path
      click_button 'oauthAuthorize'
    end

    access_grant = Opro::Oauth::AuthGrant.where(:user_id => @user.id, :application_id => @app.id).first
    assert_equal @redirect_uri, current_path
    assert access_grant.present?
    assert access_grant.can?(:write) # write access is checked by default
  end

  test 'user can remove permissions' do
    as_user(@user).visit oauth_new_path(:client_id => @app.client_id, :redirect_uri => @redirect_uri)

    uncheck('permissions_write') # uncheck write access
    click_button 'oauthAuthorize'
    access_grant = Opro::Oauth::AuthGrant.where(:user_id => @user.id, :application_id => @app.id).first
    refute access_grant.can?(:write)
  end
end
