class ApplicationController < ActionController::Base
  around_filter      :oauth_auth!
  skip_before_filter :verify_authenticity_token, :if => :valid_oauth?


  protected

    def oauth?
      params[:access_token].present?
    end

    def oauth_user
      @oauth_user ||= Oauth::AccessGrant.find_user_for_token(params[:access_token])
    end

    def valid_oauth?
      oauth? && oauth_user.present?
    end

    def oauth_auth!
      ::Opro.login(current_user)  if valid_oauth?
      yield
      ::Opro.logout(current_user) if valid_oauth?
    end
end
