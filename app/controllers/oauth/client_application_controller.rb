class Oauth::ClientApplicationController < ApplicationController
  before_filter :authenticate_user!

  def new
    @client_app = Oauth::ClientApplication.new
  end

  def create
    @client_app = Oauth::ClientApplication.create_with_user_and_name(current_user, params[:oauth_client_application][:name])
  end

  def index
    @client_apps = Oauth::ClientApplication.where(:user_id => current_user.id)
  end
end