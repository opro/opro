class Oauth::AuthController < ApplicationController
  before_filter      :authenticate_user!,         :except => [:access_token]
  skip_before_filter :verify_authenticity_token,  :only => [:access_token, :user]
  before_filter      :ask_user!,                  :only => :authorize

  def new
    @redirect_uri = params[:redirect_uri]
    @client_app   = Oauth::ClientApplication.find_by_app_id(params[:client_id])
  end

  def authorize
    application  =   Oauth::ClientApplication.find_by_app_id(params[:client_id])
    access_grant =   current_user.access_grants.where(:application_id => application.id).first
    access_grant ||= current_user.access_grants.create(:application => application)
    redirect_to access_grant.redirect_uri_for(params[:redirect_uri])
  end

  def access_token
    application = Oauth::ClientApplication.authenticate(params[:client_id], params[:client_secret])

    if application.nil?
      render :json => {:error => "Could not find application"}
      return
    end

    access_grant = Oauth::AccessGrant.authenticate(params[:code], application.id)

    if access_grant.nil?
      render :json => {:error => "Could not authenticate access code"}
      return
    end

    access_grant.start_expiry_period!
    render :json => {:access_token => access_grant.access_token, :refresh_token => access_grant.refresh_token, :expires_in => access_grant.access_token_expires_at}
  end

  # When a user is sent to authorize an application they must first accept the authorization
  # if they've already authed the app, they skip this section
  def ask_user!
    if user_granted_access_before?(current_user, params)
      # Re-Authorize the application, do not ask the user
      return true
    elsif user_authorizes_the_request?(request)
      # Authorize the application, do not ask the user
      return true
    else
      # if the request did not come from a form within the application, render the user form
      @redirect_uri ||= params[:redirect_uri]
      @client_app   ||= Oauth::ClientApplication.find_by_app_id(params[:client_id])
      redirect_to oauth_new_path(params)
    end
  end

  private
  def user_granted_access_before?(user, params)
    @client_app ||= Oauth::ClientApplication.find_by_app_id(params[:client_id])
    Oauth::AccessGrant.where(:application_id => @client_app.id, :user_id => user.id).present?
  end


  # We're verifying that a post was made from our own site, indicating a user confirmed via form
  def user_authorizes_the_request?(request)
    request.post? && referrer_is_self?(request)
  end

  # Ensures that the referrer is also the current host, to prevent spoofing
  def referrer_is_self?(request)
    return false if request.referrer.blank?
    referrer_host = URI.parse(request.referrer).host
    self_host     = URI.parse(request.url).host
    referrer_host == self_host
  end

end