module Opro

  def self.setup
    yield self
    set_login_logout_methods
  end

  def self.set_login_logout_methods
    case auth_strategy
    when :devise
      login_method  {|current_user| sign_in(current_user, :bypass => true)}
      logout_method {|current_user| sign_out(current_user) }
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


  def self.auth_strategy(auth_strategy = nil)
    if auth_strategy.present?
      @auth_strategy = auth_strategy
    else
      @auth_strategy
    end
  end


  def self.login_method(&block)
    if block.present?
      @login_method = block
    else
      @login_method or raise 'login method not set, please specify Opro auth_strategy'
    end
  end


  def self.logout_method(&block)
    if block.present?
      @logout_method = block
    else
      @logout_method or raise 'login method not set, please specify Opro auth_strategy'
    end
  end
end

# require 'opro/controller/concerns/render_redirect'
# require 'opro/controller/concerns/steps'
# require 'opro/controller/concerns/path'
require 'opro/engine'