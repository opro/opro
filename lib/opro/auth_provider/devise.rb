module Opro
  module AuthProvider
    class Devise
      attr_reader :controller

      def initialize(controller)
        @controller = controller
      end

      def login_method(current_user)
        controller.bypass_sign_in(current_user)
      end

      def logout_method(current_user)
        controller.sign_out(current_user)
      end

      def authenticate_user_method
        controller.authenticate_user!
      end

      def find_user_for_auth(params)
        return false if params[:password].blank?
        find_params = params.permit!.to_h.each_with_object({}) {|(key,value), hash| hash[key] = value if ::Devise.authentication_keys.include?(key.to_sym) }
        # Try to get fancy, some clients have :username hardcoded, if we have nothing in our find hash
        # we can make an educated guess here
        if find_params.blank? && params[:username].present?
          find_params = { ::Devise.authentication_keys.first => params[:username] }
        end
        user = User.where(find_params).first if find_params.present?
        return false unless user.present?
        return false unless user.valid_password?(params[:password])
        user
      end
    end
  end
end
