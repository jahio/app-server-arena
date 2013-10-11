require 'rubygems'
require 'bundler'
require 'sinatra/base'
require 'yaml'
require 'oauth'
require 'pry' unless ENV['RACK_ENV'] == 'production' # No pry in prod!
require 'json'

Bundler.require(ENV['RACK_ENV'] || :default)

require './app.rb'
run AppServerArena