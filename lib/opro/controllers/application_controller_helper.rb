# this concern gets put into ApplicationController

module Opro
  module Controllers
    module ApplicationControllerHelper
      extend ActiveSupport::Concern

      include Opro::Controllers::Concerns::Permissions
      include Opro::Controllers::Concerns::ErrorMessages
      include Opro::Controllers::Concerns::RateLimits

      included do
        around_filter      :oauth_auth!
        skip_before_filter :verify_authenticity_token, :if => :valid_oauth?, :raise => false
      end

      def opro_authenticate_user!
        Opro.authenticate_user_method.call(self)
        true
      end

      module ClassMethods
        def allow_oauth!(options = {})
          prepend_before_filter :allow_oauth, options
        end

        def disallow_oauth!(options = {})
          prepend_before_filter :disallow_oauth,  options
          skip_before_filter    :allow_oauth,     options
        end

      end

      protected

      def oauth_fail_request!
        render :json => {:errors => generate_oauth_error_message! }, :status => :unauthorized
        false
      end

      def allow_oauth?
        @use_oauth ||= false
      end


      def valid_oauth?
        oauth? && oauth_user.present? && oauth_client_not_expired? && oauth_client_has_permissions? && oauth_client_under_rate_limit?
      end

      def oauth_client_not_expired?
        oauth_access_grant.not_expired?
      end

      def disallow_oauth
        @use_oauth = false
      end

      def allow_oauth
        @use_oauth = true
      end

      def oauth_access_token
        params[:access_token] || oauth_access_token_from_header
      end

      # grabs access_token from header if one is present
      def oauth_access_token_from_header
        auth_header = request.env["HTTP_AUTHORIZATION"]||""
        match       = auth_header.match(/token\W*([^\W]*)/) || auth_header.match(/^Bearer\s(.*)/) || auth_header.match(Opro.header_auth_regex)
        return match[1] if match.present?
        false
      end

      def oauth?
        allow_oauth? && oauth_access_token.present?
      end

      # Override with custom logic to exclude or allow applications from exchanging
      # passwords for access_tokens
      def oauth_valid_password_auth?(client_id, client_secret)
        true
      end

      def oauth_access_grant
        @oauth_access_grant ||= Opro::Oauth::AuthGrant.find_for_token(oauth_access_token)
      end

      def oauth_client_app
        return false      if oauth_access_grant.blank?
        @oauth_client_app ||= oauth_access_grant.client_application
      end

      def oauth_user
        return false if oauth_access_grant.blank?
        @oauth_user  ||= oauth_access_grant.user
      end

      def oauth_auth!
        ::Opro.login(self, oauth_user)  if valid_oauth?
        yield
        ::Opro.logout(self, oauth_user) if valid_oauth?
      end

    end
  end
end
