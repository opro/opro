# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"

begin
  if RUBY_VERSION >= "1.9"
    require 'simplecov'
    SimpleCov.start 'rails'
  end
rescue LoadError => e
end

ENGINE_RAILS_ROOT=File.join(File.dirname(__FILE__), '../')
require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"

require 'mocha/setup'
require 'timecop'
require 'database_cleaner'
DatabaseCleaner.strategy = :truncation

ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.default_url_options[:host] = "test.com"

Rails.backtrace_cleaner.remove_silencers!

# Configure capybara for integration testing
require "capybara/rails"
Capybara.default_driver   = :rack_test
Capybara.default_selector = :css



# Run any available migration
ActiveRecord::Migration.verbose = false
ActiveRecord::Base.logger = Logger.new(nil)


ActiveRecord::Migrator.migrate File.expand_path("../dummy/db/migrate/", __FILE__)

class ActiveSupport::TestCase
  # include Devise::Test::ControllerHelpers

  self.use_transactional_tests = true
  self.use_instantiated_fixtures  = false
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
end

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }


# gives us the login_as(@user) method when request object is not present
include Warden::Test::Helpers
Warden.test_mode!

def rand_name
  'foo' + Time.now.to_f.to_s + rand(10000).to_s
end


def create_user(options = {})
  user = User.new
  user.email = rand_name + '@bar.com'
  user.password              = 'password'
  user.password_confirmation = 'password'
  user.save
  user
end

def create_client_app(options= {})
  user = options[:user] || create_user
  name = options[:name] || rand_name
  Opro::Oauth::ClientApp.create_with_user_and_name(user, name)
end

def user_with_client_app
  user = create_user
  create_client_app(:user => user)
  user
end

def create_auth_grant_for_user(user = nil, app = nil)
  app  ||= create_client_app
  user ||= create_user
  auth_grant = Opro::Oauth::AuthGrant.new
  auth_grant.user        = user
  auth_grant.application = app
  auth_grant.save
  auth_grant
end

alias :create_auth_grant :create_auth_grant_for_user


# Will run the given code as the user passed in
def as_user(user=nil, &block)
  current_user = user || create_user
  if self.respond_to? :request
    sign_in(current_user)
  else
    login_as(current_user, :scope => :user)
  end
  block.call if block.present?
  return self
end


def as_visitor(user=nil, &block)
  current_user = user || create_user
  if self.respond_to? :request
    sign_out(current_user)
  else
    logout(:user)
  end
  block.call if block.present?
  return self
end

