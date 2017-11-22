source "https://rubygems.org"

rails_version = ENV["RAILS_VERSION"] || "default"

rails = case rails_version
when "master"
  {github: "rails/rails"}
when "default"
  "~> 5.0.6"
else
  "~> #{rails_version}"
end

devise = case rails_version
when "master"
  {github: "plataformatec/devise"}
when /pre/
  {github: "plataformatec/devise", branch: "rails4"}
when "3.1.0", "3.2.0"
  "~> 2.2"
when "default"
  "~> 4.3.0"
end

gem "rails", rails

gem 'kramdown' # pure ruby markdown parser

gem 'jbuilder'

group :development, :test do
  gem 'mocha', :require => false
  gem 'timecop'
  gem 'jeweler',  "~> 1.6.4"

  gem "capybara", ">= 0.4.0"

  gem "launchy"

  gem "sqlite3",                          :platform => [:ruby, :mswin, :mingw]

  gem "activerecord-jdbcsqlite3-adapter", '>= 1.3.0.beta', :platform => :jruby
  gem "jdbc-sqlite3",                     :platform => :jruby

  gem "devise", devise if devise
end

group :test do
  gem 'database_cleaner'
end
