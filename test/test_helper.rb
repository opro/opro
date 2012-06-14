# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"


ENGINE_RAILS_ROOT=File.join(File.dirname(__FILE__), '../')
require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"

require 'mocha'

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
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
end

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }



include Devise::TestHelpers

# gives us the login_as(@user) method when request object is not present
include Warden::Test::Helpers
Warden.test_mode!

def rand_name
  'foo' + Time.now.to_f.to_s
end


def create_user(options = {})
  User.create(:email => rand_name + '@bar.com', :password => 'password', :password_confirm => 'password')
end

def create_client_app(options= {})
  user = options[:user] || create_user
  name = options[:name] || rand_name
  Oauth::ClientApplication.create_with_user_and_name(user, name)
end

def user_with_client_app
  user = create_user
  create_client_app(:user => user)
  user
end

def create_auth_grant_for_user(user = nil, app = nil)
  app  ||= create_client_app
  user ||= create_user
  Oauth::AccessGrant.create(:user => user, :application => app)
end

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

