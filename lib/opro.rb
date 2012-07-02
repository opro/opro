module Opro
  module Oauth
  end
  module Controllers
    module Concerns
    end
  end

  # Include helpers in the given scope to AC and AV.
  def self.include_helpers(scope)
    ActiveSupport.on_load(:action_controller) do
      include scope::ApplicationControllerHelper if defined?(scope::ApplicationControllerHelper)
    end
  end


  def self.setup
    yield self
    set_login_logout_methods
  end

  def self.set_login_logout_methods
    case auth_strategy
    when :devise
      login_method             { |controller, current_user| controller.sign_in(current_user, :bypass => true) }
      logout_method            { |controller, current_user| controller.sign_out(current_user) }
      authenticate_user_method { |controller| controller.authenticate_user! }

      find_user_for_auth do |controller, params|
        return false if params[:password].blank?
        find_params = params.each_with_object({}) {|(key,value), hash| hash[key] = value if Devise.authentication_keys.include?(key.to_sym) }
        user        = User.where(find_params).first if find_params.present?
        return false unless user.present?
        return false unless user.valid_password?(params[:password])
        user
      end
    else
      # nothing
    end
  end

  # Used by application controller to log user in
  def self.login(*args)
    raise 'login method not set, please specify Opro auth_strategy' if login_method.blank?
    login_method.call(*args)
  end

  # Used by application controller to log user out
  def self.logout(*args)
    raise 'login method not set, please specify Opro auth_strategy' if login_method.blank?
    logout_method.call(*args)
  end

  # Used by set_login_logout_methods to pre-define login, logout, and authenticate methods
  def self.auth_strategy(auth_strategy = nil)
    if auth_strategy.present?
      @auth_strategy = auth_strategy
    else
      @auth_strategy
    end
  end

  def self.auth_strategy=(auth_strategy)
    @auth_strategy = auth_strategy
  end


  def self.login_method(&block)
    if block.present?
      @login_method = block
    else
      @login_method or raise 'login method not set, please specify Opro auth_strategy'
    end
  end

  def self.request_permissions=(permissions)
    @request_permissions = permissions
  end

  def self.request_permissions
    @request_permissions || []
  end

  def self.require_refresh_within=(require_refresh_within)
    @require_refresh_within = require_refresh_within
  end

  def self.require_refresh_within
    @require_refresh_within
  end

  def self.logout_method(&block)
    if block.present?
      @logout_method = block
    else
      @logout_method or raise 'login method not set, please specify Opro auth_strategy'
    end
  end

  def self.authenticate_user_method(&block)
    if block.present?
      @authenticate_user_method = block
    else
      @authenticate_user_method or raise 'authenticate_user_method not set, please specify Opro auth_strategy'
    end
  end

  # calls all of the different auths made available,
  def self.find_user_for_all_auths!(controller, params)
    @user = false
    find_user_for_auth.each do |auth_block|
      break if @user.present?
      @user = auth_block.call(controller, params)
    end
    @user
  end


  # Grossssss, don't use, needed to support `return` from the blocks provided to `find_user_for_auth`
  def self.convert_to_lambda &block
    obj = Object.new
    obj.define_singleton_method(:_, &block)
    return obj.method(:_).to_proc
  end

  # holds an Array of authentication blocks is called by find_user_for_all_auths! in token controller
  # can be used for finding users using multiple methods (password, facebook, twitter, etc.)
  def self.find_user_for_auth(&block)
    if block.present?
      @find_for_authentication ||= []
      @find_for_authentication << convert_to_lambda(&block)
    else
      @find_for_authentication or raise 'find_for_authentication not set, please specify Opro auth_strategy'
    end
  end

  def self.password_exchange_enabled=(password_exchange_enabled)
    @password_exchange_enabled = password_exchange_enabled
  end

  def self.password_exchange_enabled?
    @password_exchange_enabled
  end
end

require 'opro/controllers/concerns/rate_limits'
require 'opro/controllers/concerns/error_messages'
require 'opro/controllers/concerns/permissions'
require 'opro/controllers/application_controller_helper'
require 'opro/engine'
