source "http://rubygems.org"

gem "activesupport" , ">= 3.0.7"
gem "rails"         , ">= 3.0.7"


gem 'bluecloth'

group :development, :test do
  gem 'mocha'
  gem 'timecop'
  gem 'jeweler',  "~> 1.6.4"
  gem "bundler",  ">= 1.1.3"


  gem "capybara", ">= 0.4.0"
  gem "sqlite3"
  gem "launchy"
end

group :test do
  gem 'database_cleaner'
end

group :test, :development do
  gem 'devise'
end


platforms :mri_18 do
  group :development, :test do
    gem "rcov"
  end
end

platforms :mri_19 do
  group :development, :test do
    gem "simplecov"
  end
end

# To use debugger (ruby-debug for Ruby 1.8.7+, ruby-debug19 for Ruby 1.9.2+)
# gem 'ruby-debug'
# gem 'ruby-debug19'
