# this concern gets put into ApplicationController

module Opro
  module Controllers
    module ApplicationControllerHelper
      extend ActiveSupport::Concern

      include Opro::Controllers::Concerns::Permissions
      include Opro::Controllers::Concerns::ErrorMessages

      included do
        around_filter      :oauth_auth!
        skip_before_filter :verify_authenticity_token, :if => :valid_oauth?
      end

      def opro_authenticate_user!
        Opro.authenticate_user_method.call(self)
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

      def allow_oauth?
        @use_oauth ||= false
      end

      # returns boolean if oauth request
      def valid_oauth?
        oauth? && oauth_user.present? && oauth_client_has_permissions?
      end

      def disallow_oauth
        @use_oauth = false
      end

      def allow_oauth
        @use_oauth = true
      end

      def oauth?
        allow_oauth? && params[:access_token].present?
      end

      def oauth_access_grant
        @oauth_access_grant ||= Oauth::AccessGrant.find_for_token(params[:access_token])
      end

      def oauth_client_app
        @oauth_client_app   ||= oauth_access_grant.client_application
      end

      def oauth_user
        @oauth_user         ||= oauth_access_grant.user
      end

      def oauth_auth!
        ::Opro.login(self, oauth_user)  if valid_oauth?
        yield
        ::Opro.logout(self, oauth_user) if valid_oauth?
      end

    end
  end
end
