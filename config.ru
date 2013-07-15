# This is a check to see if the necessary twitter.yml exists.
# If not, bail out quick and don't launch.
unless File.exists?(File.join(File.dirname(__FILE__), 'config', 'twitter.yml'))
  $stderr.puts "Didn't find config/twitter.yml. Make sure it exists and has valid credentials, then start this again."
  exit!(false)
end

require 'rubygems'
require 'bundler'
require 'sinatra/base'
require 'yaml'
require 'oauth'
require 'pry' unless ENV['RACK_ENV'] == 'production' # No pry in prod!
require 'json'

Bundler.require(ENV['RACK_ENV'] || :default)

require './app.rb'
run MyApp