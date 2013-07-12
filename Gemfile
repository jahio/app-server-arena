source 'https://rubygems.org'

gem 'sinatra'
gem 'json'
gem 'oauth'
gem 'pry' # obviously don't do this in prod, just for demo purposes

group :app_servers do
  gem 'puma', require: 'puma' # doesn't show up otherwise for some reason
  gem 'unicorn'
  gem 'thin'
end