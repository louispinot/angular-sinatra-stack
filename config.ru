require 'sinatra'
require 'rubygems'

disable :run
require File.expand_path( '../core.api/app.rb', __FILE__ )

run Sinatra::Application


