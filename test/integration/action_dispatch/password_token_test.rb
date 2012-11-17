## NOT CAPYBARA
#  ActionDispatch::IntegrationTest
#  http://guides.rubyonrails.org/testing.html#integration-testing
#  used so we can test POST actions ^_^

require 'test_helper'

class PasswordTokenTest < ActionDispatch::IntegrationTest

  setup do
    @user         = create_user
    @client_app   = create_client_app
    @password     = "password"
    Opro.setup {|config| config.password_exchange_enabled = true}
  end


  test "exchange a password and email for an access_token" do
    params = {:client_id      => @client_app.client_id ,
              :client_secret  => @client_app.client_secret,
              :password       => @password,
              :email          => @user.email }

    post oauth_token_path(params)

    json_hash = JSON.parse(response.body)
    assert json_hash['access_token'].present?
  end

  test "do not provide access_token for invalid password or email" do
    params = {:client_id      => @client_app.client_id ,
              :client_secret  => @client_app.client_secret,
              :password       => @password,
              :email          => @user.email }

    post oauth_token_path(params.merge(:password => @password + "invalid"))
    json_hash = JSON.parse(response.body)
    assert json_hash['access_token'].blank?

    post oauth_token_path(params.merge(:email    => "invalid" + @user.email ))
    json_hash = JSON.parse(response.body)
    assert json_hash['access_token'].blank?
  end

  test "Only allow authenticated apps" do
    Opro::Oauth::TokenController.any_instance.stubs(:oauth_valid_password_auth?).
                          with(@client_app.client_id, @client_app.client_secret).
                          returns(false)

    params = {:client_id      => @client_app.client_id ,
              :client_secret  => @client_app.client_secret,
              :password       => @password,
              :email          => @user.email }

    post oauth_token_path(params)
    json_hash = JSON.parse(response.body)
    assert json_hash['access_token'].blank?
  end


  test "Allow multiple definitions of find_user_for_auth (no password)" do
    Opro.setup do |config|
      config.find_user_for_auth do |controller, params|
        return false if params[:special_key].blank?
        user = User.last if params[:special_key] == "fooBarzyrhaz"
        user
      end
    end

    params = {:client_id      => @client_app.client_id ,
              :client_secret  => @client_app.client_secret,
              :special_key    => "fooBarzyrhaz",
              :grant_type     => 'password' }

    post oauth_token_path(params)
    json_hash = JSON.parse(response.body)
    assert json_hash['access_token'].present?
  end
 
  test "access_token is stays valid in expires_in period" do
    Timecop.freeze(Time.now)
    params = {:client_id      => @client_app.client_id ,
              :client_secret  => @client_app.client_secret,
              :password       => @password,
              :email          => @user.email }

    post oauth_token_path(params)
    json_hash = JSON.parse(response.body)
    expires_in = json_hash['expires_in']
    access_token = json_hash['access_token']
    Timecop.travel(expires_in.from_now)
    get "/?access_token=#{access_token}"
    assert_no_match /NO logged in users/, response.body
  end

  test "access_token is not valid after expires_in has passed" do
    Timecop.freeze(Time.now)
    params = {:client_id      => @client_app.client_id ,
              :client_secret  => @client_app.client_secret,
              :password       => @password,
              :email          => @user.email }

    post oauth_token_path(params)
    json_hash = JSON.parse(response.body)
    expires_in = json_hash['expires_in'] + 1
    access_token = json_hash['access_token']
    Timecop.travel(expires_in.from_now)
    get "/?access_token=#{access_token}"
    assert_match /NO logged in users/, response.body
  end

  test "reported expires_in after revalidating is correct" do
    Timecop.freeze(Time.now)
    params = {:client_id      => @client_app.client_id ,
              :client_secret  => @client_app.client_secret,
              :password       => @password,
              :email          => @user.email }

    post oauth_token_path(params)
    Timecop.travel(1.day.from_now)
    post oauth_token_path(params)
    json_hash = JSON.parse(response.body)
    expires_in = json_hash['expires_in']
    Timecop.travel(expires_in.from_now)
    access_token = json_hash['access_token']
    get "/?access_token=#{access_token}"
    assert_no_match /NO logged in users/, response.body
  end

end

