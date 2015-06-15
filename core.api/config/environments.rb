# this is necessary, as long as, the Sinatra application files reside outside of the core.api folder
CORE_API_DIRECTORY      = File.expand_path( '../', __dir__)  +  '/'
CORE_FRONTEND_DIRECTORY = File.expand_path( '../../core.client/', __dir__)  +  '/'
SESSION_TIMEOUT         = 30

# ======================================================================
configure :local do
  set :environment        , :local
  set :logentries_token   , nil
  set :loglevel           , Logger::DEBUG
end #configure local

configure :development do
  set :environment        , :development
  set :logentries_token   , '96f6a1b9-08bd-4dae-8490-cd6bb7c519c9'
  set :loglevel           , Logger::DEBUG
end #configure development

configure :production do
  set :environment        , :production
  set :logentries_token   , '79dead24-9f09-4064-b7f7-370bf42ef3a5'
  set :loglevel           , Logger::DEBUG # Logger::INFO

end #configure production

# ======================================================================
# configure :production, :development, :local  do
set :rabbit_url           , ENV['RABBITMQ_URL']
set :admins               , ['admin@compass.co', 'admin@startupcompass.co']
set :public_folder        , CORE_FRONTEND_DIRECTORY
set :home_page            , CORE_FRONTEND_DIRECTORY + 'index.html'
compassshared_path = Bundler.rubygems.find_name('compassshared').first.full_gem_path
set :database_file        , File.join(compassshared_path, 'lib/compassshared/config/database.yml').to_s

if settings.logentries_token
  logger        = Le.new( settings.logentries_token, debug: (:production != settings.environment) )    # no debugging for production, but for all other environments!
else
  logger        = Logger.new( STDOUT )   # other option:  logger = Logger.new( '/var/log/compass_core.log' )
end #if-else

logger.level    = settings.loglevel

# dirty quickfix by Rayo:
# monkey-patching the (eigen)class of the default logger to support method "write" (which is used by Sinatra) as an alias of "<<" (which is the default method to write to the logfile)
class <<logger
  alias write <<
  def flush; end  # no need for flushing
  def puts( object )
    self.<< object.to_s rescue nil  # no logging
  end #puts()
end #eigenclass logger

enable :logging
set :logger               , logger  # setting logger access via Sinatra-settings (necessary outside of request-scope, eg. in Publisher.simple_publish

use Rack::CommonLogger    , logger  # telling Sinatra to use our logger; Sinatra will use this logger to log Apache-request-logs (eg. "GET /views/dashboard.html HTTP/1.0" 200 279 0.0012")
before do
  env['rack.errors']      = logger  # Rack uses this logger to pass to the request-scope and to log errors that make the app (Sinatra) crash. This logger is used for application-logs (created by us) and unforeseen errors.
  env['rack.logger']      = logger  # this may lead to duplicated logs (Rack and Sinatra, both logging to the same logfile); probably unnecessary, especially after calling use Rack::CommonLogger
end #before

ActiveRecord::Base.logger = logger  # telling ActiveRecord to also use our logger (instead of StdOut)

logger.info( 'Sinatra Configuration application start: environment ' + settings.environment.to_s.capitalize )