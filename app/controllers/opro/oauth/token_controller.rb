# This controller is where clients can exchange
# codes and refresh_tokens for access_tokens

class Opro::Oauth::TokenController < OproController
  before_filter      :opro_authenticate_user!,    :except => [:create]
  skip_before_filter :verify_authenticity_token,  :only   => [:create]


  def create
    # Find the client application
    application = Opro::Oauth::ClientApp.authenticate(params[:client_id], params[:client_secret])

    if application.nil?
      render :json => {:error => "Could not find application based on client_id=#{params[:client_id]}
                                  and client_secret=#{params[:client_secret]}"}, :status => :unauthorized
      return
    end

    if params[:code]
      auth_grant = Opro::Oauth::AuthGrant.auth_with_code!(params[:code], application.id)
    elsif params[:refresh_token]
      auth_grant = Opro::Oauth::AuthGrant.refresh_tokens!(params[:refresh_token], application.id)
    elsif params[:password].present? || params[:grant_type] == "password"|| params[:grant_type] == "bearer"
      user       = ::Opro.find_user_for_all_auths!(self, params) if Opro.password_exchange_enabled? && oauth_valid_password_auth?(params[:client_id], params[:client_secret])
      auth_grant = Opro::Oauth::AuthGrant.auth_with_user!(user, application.id) if user.present?
    end

    if auth_grant.blank?
      msg = "Could not find a user that belongs to this application"
      msg << " & has a refresh_token=#{params[:refresh_token]}" if params[:refresh_token]
      msg << " & has been granted a code=#{params[:code]}"      if params[:code]
      msg << " using username and password"                   if params[:password]
      render :json => {:error => msg }, :status => :unauthorized
      return
    end

    auth_grant.generate_expires_at!
    render :json => { :access_token   => auth_grant.access_token,
                      :refresh_token  => auth_grant.refresh_token,
                      :expires_in     => auth_grant.expires_in }
  end

end