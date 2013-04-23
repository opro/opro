class Opro::Oauth::ClientAppController < OproController
  before_filter :opro_authenticate_user!
  before_filter :client_app, only: [:show, :edit, :update, :create]

  def new
    @client_app = Opro::Oauth::ClientApp.new
  end

  # Show all client applications belonging to the current user
  def index
    @client_apps = Opro::Oauth::ClientApp.where(user_id: current_user.id)
  end

  def show
  end

  def edit
  end

  def update
    @client_app.name = params[:opro_oauth_client_app][:name]
    if @client_app.save
      redirect_to oauth_client_app_path(@client_app)
    else
      render :edit
    end
  end

  def create
    @client_app ||= Opro::Oauth::ClientApp.create_with_user_and_name(current_user, params[:opro_oauth_client_app][:name])
    if @client_app.save
      redirect_to oauth_client_app_path(@client_app)
    else
      render :new
    end
  end

  def client_app
    @client_app ||= Opro::Oauth::ClientApp.where(id: params[:id], user_id: current_user.id).first
  end
end
