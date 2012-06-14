module Opro
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
    else
      # nothing
      # TODO, be smart here, if they have devise gem in Gemfile and haven't specified auth_strategy use devise
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
      @authenticate_user_method or raise 'authenticate user method not set, please specify Opro auth_strategy'
    end
  end
end

require 'opro/controllers/concerns/error_messages'
require 'opro/controllers/concerns/permissions'
require 'opro/controllers/application_controller_helper'
require 'opro/engine'
