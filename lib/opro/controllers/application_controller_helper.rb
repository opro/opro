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

      def oauth_user
        @oauth_user ||= Oauth::AccessGrant.find_user_for_token(params[:access_token])
      end

      def valid_oauth?
        oauth? && oauth_user.present?
      end

      def oauth_auth!
        ::Opro.login(self, oauth_user)  if valid_oauth?
        yield
        ::Opro.logout(self, oauth_user) if valid_oauth?
      end

    end
  end
end
