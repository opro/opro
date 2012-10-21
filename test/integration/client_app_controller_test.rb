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

    fill_in 'opro_oauth_client_app_name', :with => rand_name

    click_button 'submitApp'
    assert_match /oauth_client_apps\/\d*/, current_path

    last_client = Opro::Oauth::ClientApp.order(:created_at).last
    assert has_content?(last_client.name)
    assert has_content?(last_client.client_id)
    assert has_content?(last_client.client_secret)
  end

  test 'edit existing client application' do
    app = create_client_app
    as_user(app.user).visit oauth_client_app_path(app)

    click_link "edit"

    assert_equal edit_oauth_client_app_path(app), current_path
    new_name = rand_name
    old_name = app.name
    refute new_name == old_name # smoke test

    fill_in "opro_oauth_client_app_name", :with => new_name
    click_button 'submitApp'

    assert has_content?(new_name)
  end

  test 'index client applications' do
    app = create_client_app
    create_client_app(:user => app.user)
    create_client_app(:user => app.user)

    as_user(app.user).visit oauth_client_apps_path
    assert_equal oauth_client_apps_path, current_path
  end

end
