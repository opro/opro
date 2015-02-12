# This controller is where clients can exchange
# codes and refresh_tokens for access_tokens

class Opro::Oauth::TokenController < OproController
  before_filter      :opro_authenticate_user!,    :except => [:create]
  skip_before_filter :verify_authenticity_token,  :only   => [:create]


  def create
    # Find the client application
    application = Opro::Oauth::ClientApp.authenticate(params[:client_id], params[:client_secret])

    if application.present? && (auth_grant = auth_grant_for(application, params)).present?
      auth_grant.refresh!
      render :json => { access_token:  auth_grant.access_token,
                        # http://tools.ietf.org/html/rfc6749#section-5.1
                        token_type:    Opro.token_type || 'bearer',
                        refresh_token: auth_grant.refresh_token,
                        expires_in:    auth_grant.expires_in }
    else
      render_error debug_msg(params, application)
    end
  end

  private

  def auth_grant_for(application, params)
    if params[:code]
      Opro::Oauth::AuthGrant.find_by_code_app(params[:code], application)
    elsif params[:refresh_token]
      Opro::Oauth::AuthGrant.find_by_refresh_app(params[:refresh_token], application)
    elsif params[:password].present? || params[:grant_type] == "password"|| params[:grant_type] == "bearer"
      return false unless Opro.password_exchange_enabled?
      return false unless oauth_valid_password_auth?(params[:client_id], params[:client_secret])
      user       = ::Opro.find_user_for_all_auths!(self, params)
      return false unless user.present?
      auth_grant = Opro::Oauth::AuthGrant.find_or_create_by_user_app(user, application)
      auth_grant.update_permissions if auth_grant.present?
      auth_grant
    end
  end

  def debug_msg(options, app)
    msg = "Could not find a user that belongs to this application"
    msg << " based on client_id=#{options[:client_id]} and client_secret=#{options[:client_secret]}" if app.blank?
    msg << " & has a refresh_token=#{options[:refresh_token]}" if options[:refresh_token]
    msg << " & has been granted a code=#{options[:code]}"      if options[:code]
    msg << " using username and password"                      if options[:password]
    msg
  end

  def render_error(msg)
    render :json => {:error => msg }, :status => :unauthorized
  end

end
