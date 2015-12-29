source "https://rubygems.org"

ruby `cat .ruby-version`.strip

gem "sinatra"
gem "octokit"
gem "dotenv"
gem "rack-ssl-enforcer"
gem "sinatra_auth_github"
gem "rack-coffee"
gem 'sinatra-redirect-with-flash'
gem 'rack-flash3'
gem 'moneta'
gem 'redis'
gem 'rake'

group :development do
  gem "pry"
  gem "rerun"
end

group :test do
  gem 'rspec'
  gem 'rack-test'
  gem 'webmock'
end
