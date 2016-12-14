class Opro::Oauth::AuthController < OproController
  before_action      :opro_authenticate_user!
  before_action      :ask_user!,                  :only   => [:create]

  def new
    @redirect_uri = params[:redirect_uri]
    @client_app   = Opro::Oauth::ClientApp.find_by_app_id(params[:client_id])
    @scopes       = scope_from_params(params)
  end

  # :ask_user! is called before creating a new authorization, this allows us to redirect
  def create
    # find or create an auth_grant for a given user
    application = Opro::Oauth::ClientApp.find_by_client_id(params[:client_id])
    auth_grant  = Opro::Oauth::AuthGrant.find_or_create_by_user_app(current_user, application)

    # add permission changes if there are any
    auth_grant.update_permissions(params[:permissions])
    redirect_to auth_grant.redirect_uri_for(params[:redirect_uri], params[:state])
  end


  private
  # When a user is sent to authorize an application they must first accept the authorization
  # if they've already authed the app, they skip this section
  def ask_user!
    if user_granted_access_before?(current_user, params)
      # Re-Authorize the application, do not ask the user
      params.delete(:permissions) ## Delete permissions supplied by client app, this was a security hole
      return true
    elsif user_authorizes_the_request?(request)
      # The user just authorized the application from the form
      return true
    else

      # if the request did not come from a form within the application, render the user form
      @redirect_uri ||= params[:redirect_uri]
      @client_app   ||= Opro::Oauth::ClientApp.find_by_app_id(params[:client_id])
      params.delete("action").delete("controller")
      redirect_to oauth_new_path(params)
    end
  end

  def user_granted_access_before?(user, params)
    @client_app ||= Opro::Oauth::ClientApp.find_by_app_id(params[:client_id])
    return false if user.blank? || @client_app.blank?
    Opro::Oauth::AuthGrant.where(:application_id => @client_app.id, :user_id => user.id).present?
  end

  # Verifying that a post was made from our own site, indicating a user confirmed via form
  def user_authorizes_the_request?(request)
    request.post? && referrer_is_self?(request)
  end

  # Ensures that the referrer is the current host, to prevent spoofing
  def referrer_is_self?(request)
    return false if request.referrer.blank?
    referrer_host = URI.parse(request.referrer).host
    self_host     = URI.parse(request.url).host
    referrer_host == self_host
  end


  # take params[:scope] = [:write, :read, :etc] or
  # take params[:scope] = "write, read, etc"
  # compare against available scopes ::Opro.request_permissions
  # return the intersecting set. or the default scope
  def scope_from_params(params)
    return default_scope if params[:scope].blank?
    scope = params[:scope].is_a?(Array) ? params[:scope] : params[:scope].split(',')
    scope = scope.map(&:downcase).map(&:strip)
    return scope & default_scope
  end

  def default_scope
    ::Opro.request_permissions.map(&:to_s).map(&:downcase)
  end
end
