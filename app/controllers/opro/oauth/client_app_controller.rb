class Opro::Oauth::ClientAppController < OproController
  before_action :opro_authenticate_user!

  def new
    @client_app = Opro::Oauth::ClientApp.new
  end

  # Show all client applications belonging to the current user
  def index
    @client_apps = Opro::Oauth::ClientApp.where(user_id: current_user.id)
    @all_apps_count = Opro::Oauth::ClientApp.count
  end

  def show
    @client_app = client_app
  end

  def edit
    @client_app = client_app
  end

  def update
    @client_app = client_app
    @client_app.name = params[:opro_oauth_client_app][:name]
    if @client_app.save
      redirect_to oauth_client_app_path(@client_app)
    else
      render :edit
    end
  end

  def create
    @client_app = client_app
    @client_app ||= Opro::Oauth::ClientApp.create_with_user_and_name(current_user, params[:opro_oauth_client_app][:name])
    if @client_app.save
      redirect_to oauth_client_app_path(@client_app)
    else
      render :new
    end
  end

  def destroy
    @client_app = client_app
    @client_app.destroy
    redirect_to oauth_client_apps_path
  end

  def client_app
    Opro::Oauth::ClientApp.where(id: params[:id], user_id: current_user.id).first
  end
end
