source "http://rubygems.org"

gem "activesupport" , ">= 3.1.0"
gem "rails"         , ">= 3.1.0"


gem 'kramdown' # pure ruby markdown parser

group :development, :test do
  gem 'mocha'
  gem 'timecop'
  gem 'jeweler',  "~> 1.6.4"
  gem "bundler",  ">= 1.1.3"

  gem "capybara", ">= 0.4.0"

  gem "launchy"

  gem "sqlite3",                          :platform => [:ruby, :mswin, :mingw]
  gem "activerecord-jdbcsqlite3-adapter", :platform => :jruby
  gem "jdbc-sqlite3",                     :platform => :jruby

  gem 'devise'
end

group :test do
  gem 'database_cleaner'
end
