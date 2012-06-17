# This controller is where clients can exchange
# codes and refresh_tokens for access_tokens

class Oauth::TokenController < OproController
  before_filter      :opro_authenticate_user!,    :except => [:create]
  skip_before_filter :verify_authenticity_token,  :only   => [:create]


  def create
    application = Oauth::ClientApp.authenticate(params[:client_id], params[:client_secret])

    if application.nil?
      render :json => {:error => "Could not find application"}
      return
    end

    if params[:code]
      access_grant = Oauth::AuthGrant.authenticate(params[:code], application.id)
    else
      access_grant = Oauth::AuthGrant.refresh_tokens!(params[:refresh_token], application.id)
    end

    if access_grant.nil?
      render :json => {:error => "Could not authenticate access code"}
      return
    end

    access_grant.generate_expires_at!
    render :json => { :access_token   => access_grant.access_token,
                      :refresh_token  => access_grant.refresh_token,
                      :expires_in     => access_grant.expires_in }
  end

end