class Oauth::ClientAppController < OproController
  before_filter :opro_authenticate_user!

  def new
    @client_app = Oauth::ClientApp.new
  end

  def create
    @client_app = Oauth::ClientApp.find_by_user_id_and_name(current_user.id, params[:oauth_client_app][:name])
    @client_app ||= Oauth::ClientApp.create_with_user_and_name(current_user, params[:oauth_client_app][:name])
    if @client_app.save
      # do nothing
    else
      render :new
    end
  end

  def index
    @client_apps = Oauth::ClientApp.where(:user_id => current_user.id)
  end
end