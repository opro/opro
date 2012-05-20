# this concern gets put into ApplicationController

module Opro
  module Controllers
    module ApplicationControllerHelper
      extend ActiveSupport::Concern

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

        # call this to remove permissions
        def require_oauth_permissions(*permissions)
          prepend_before_filter do
            @oauth_required_permissions = permissions
          end
        end
        alias :require_oauth_permission :require_oauth_permissions
      end

      protected

      def allow_oauth?
        @use_oauth ||= false
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

      def valid_oauth?
        oauth? && oauth_user.present? && has_permission?
      end

      def oauth_required_permissions
        @oauth_required_permissions || []
      end


      def has_permission?
        if Opro.request_permissions.include?(:write) && !oauth_access_grant.can_write?
          return false if env['REQUEST_METHOD'] != 'GET'
        end

        return false if (oauth_required_permissions - oauth_access_grant.permissions.keys).present?
        true
      end

      def oauth_auth!
        ::Opro.login(self, oauth_user)  if valid_oauth?
        yield
        ::Opro.logout(self, oauth_user) if valid_oauth?
      end

    end
  end
end
