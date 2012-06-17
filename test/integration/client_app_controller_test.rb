require 'test_helper'

class ClientAppControllerTest < ActiveSupport::IntegrationCase
  test 'must be logged in' do
    visit new_oauth_client_app_path
    assert_equal '/users/sign_in', current_path
  end

  test 'create client application' do
    user = create_user
    as_user(user).visit new_oauth_client_app_path
    assert_equal '/oauth_client_apps/new', current_path

    fill_in 'oauth_client_app_name', :with => rand_name

    click_button 'submitApp'
    assert_equal '/oauth_client_apps', current_path

    last_client = Oauth::ClientApp.order(:created_at).last
    assert has_content?(last_client.name)
    assert has_content?(last_client.client_id)
    assert has_content?(last_client.client_secret)
  end
end
