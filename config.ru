# config.ru
require 'rubygems'
require 'sinatra'
require 'sinatra/base'
require 'faraday'
require 'json'

require File.expand_path '../classes/helpers.rb', __FILE__
require File.expand_path '../classes/utilities.rb', __FILE__
require File.expand_path '../app.rb', __FILE__

run App