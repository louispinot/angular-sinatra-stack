# Don't delete this code, godamnit!
# If you don't like this setting of Environment-variables, talk to me (Rayo) first, please!
# This code should be used from CompassData/constants!
ENV['APP_ENV']          = ENV['APP_ENV']  ||  ENV['RACK_ENV']  ||  ENV['RAILS_ENV']  ||  'development'
ENV['RACK_ENV']         = ENV['RAILS_ENV']  =  ENV['APP_ENV']

require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'sinatra/activerecord'
require 'bundler'
require 'rack/ssl-enforcer'
require_relative 'config/environments'

# Redirects non-SSL (http) requests to https-website, enforcing SSL-usage and preventing DC
# use Rack::SslEnforcer, :only_hosts => ['www.compass.co','compass.co','core.compass.co', 'beta.core.compass.co', 'beta.compass.co']

# this is necessary, as long as the Sinatra application files reside outside of the core.api folder
# This fix has to be propagated to config/environments.rb and ../config.ru
# The following files will have to be moved depending on where the Unicorn-server is started: Gemfile*, config.ru, unicorn.rb, start/stop_server.sh
# Additionally, there has to be symlink "config" to "core.api/config" folder in order to allow a local Unicorn server to properly connect to the DB-server
api_directory = 'core.api/'
require_relative 'extensions/authentication'
require_relative 'extensions/helpers'
Dir['./%sroutes/*.rb' % api_directory].each {|file| require file}
Dir['./%sservices/*.rb' % api_directory].each {|file| require file}


Bundler.require :default, ENV['RACK_ENV'].to_sym

# default mime-type of this webserver
before do
  content_type 'application/json'
end

# application page; loads the index.html page when we run app.rb

get '/*' do
  content_type 'text/html'
  File.read settings.home_page
end

# start console:  `APP_ENV=production  bundle exec ruby  ./core.api/app.rb  console`
if ['console', 'c'].include?( ARGV.first )  ||  false
  printf "\nWelcome to your Sinatra-console in <%s> environment. Enter `exit` to close the console.\n", settings.environment.to_s.capitalize
  print '='*99, "\n"
  require 'pry'
  binding.pry
  exit
end #if