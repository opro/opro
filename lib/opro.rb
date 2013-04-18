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

  # sets up defaults for common auth providers
  def self.set_login_logout_methods
    klass = case auth_strategy
    when :devise
      AuthProvider::Devise
    else
      auth_strategy if auth_strategy.is_a? Class
    end
    return false unless klass.present?
    login_method             { |controller, current_user| klass.new(controller).login_method(current_user)  }
    logout_method            { |controller, current_user| klass.new(controller).logout_method(current_user) }
    find_user_for_auth       { |controller, params|       klass.new(controller).find_user_for_auth(params)  }
    authenticate_user_method { |controller|               klass.new(controller).authenticate_user_method    }
  end

  # Used by application controller to log user in
  def self.login(*args)
    raise 'login method not set; please specify an oPRO auth_strategy in config/initializers/opro.rb' if login_method.blank?
    login_method.call(*args)
  end

  # Used by application controller to log user out
  def self.logout(*args)
    raise 'logout method not set; please specify an oPRO auth_strategy in config/initializers/opro.rb' if login_method.blank?
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
      @login_method or raise 'login method not set; please specify an oPRO auth_strategy in config/initializers/opro.rb'
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
      @logout_method or raise 'logout method not set; please specify an oPRO auth_strategy in config/initializers/opro.rb'
    end
  end

  def self.authenticate_user_method(&block)
    if block.present?
      @authenticate_user_method = block
    else
      @authenticate_user_method or raise 'authenticate_user_method not set, please specify an oPRO auth_strategy in config/initializers/opro.rb'
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

  # default to no match
  def self.header_auth_regex
    @header_auth_regex || /$^/
  end


  def self.token_type=(token_type)
    @token_type = token_type
  end

  def self.token_type
    @token_type
  end

  # Allows a user to define a custom authorization regular expression
  def self.header_auth_regex=(regexstring)
    raise "not a regex" unless regexstring.is_a? Regexp
    @header_auth_regex = regexstring
  end


  # Needed to `return` from the blocks provided to `find_user_for_auth`
  def self.convert_to_lambda &block
    if RUBY_ENGINE && RUBY_ENGINE == "jruby"
      return lambda(&block)
    else
      # Grossssss, don't use
      obj = Object.new
      obj.define_singleton_method(:_, &block)
      return obj.method(:_).to_proc
    end
  end

  # holds an Array of authentication blocks is called by find_user_for_all_auths! in token controller
  # can be used for finding users using multiple methods (password, facebook, twitter, etc.)
  def self.find_user_for_auth(&block)
    if block.present?
      @find_for_authentication ||= []
      @find_for_authentication << convert_to_lambda(&block)
    else
      @find_for_authentication or raise 'find_user_for_auth not set, please specify an oPRO auth_strategy in config/initializers/opro.rb'
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
require 'opro/auth_provider/devise'
require 'opro/engine'
