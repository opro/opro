class Oauth::ClientApplicationController < ApplicationController
  before_filter :opro_authenticate_user!

  def new
    @client_app = Oauth::ClientApplication.new
  end

  def create
    @client_app = Oauth::ClientApplication.find_by_user_id_and_name(current_user.id, params[:oauth_client_application][:name])
    @client_app ||= Oauth::ClientApplication.create_with_user_and_name(current_user, params[:oauth_client_application][:name])
    if @client_app.save
      # do nothing
    else
      render :new
    end
  end

  def index
    @client_apps = Oauth::ClientApplication.where(:user_id => current_user.id)
  end
end