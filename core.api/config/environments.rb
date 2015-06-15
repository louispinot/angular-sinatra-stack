# this is necessary, as long as, the Sinatra application files reside outside of the core.api folder
CORE_API_DIRECTORY      = File.expand_path( '../', __dir__)  +  '/'
CORE_FRONTEND_DIRECTORY = File.expand_path( '../../core.client/', __dir__)  +  '/'
SESSION_TIMEOUT         = 30

# ======================================================================
configure :local do
  set :environment        , :local
end #configure local

configure :development do
  set :environment        , :development
end #configure development

configure :production do
  set :environment        , :production
end #configure production

# ======================================================================
# configure :production, :development, :local  do

set :public_folder        , CORE_FRONTEND_DIRECTORY
set :home_page            , CORE_FRONTEND_DIRECTORY + 'index.html'
# set :database_file        , ???? for Compass, this points to the .yml file in CompassShared


# configure do
#   enable :logging
#   logger = File.new("#{settings.root}/log/#{settings.environment}.log", 'a+')
#   logger.sync = true
#   use Rack::CommonLogger, logger
#   ActiveRecord::Base.logger = logger  # telling ActiveRecord to also use our logger (instead of StdOut)
# end

# before do
#   env['rack.errors']      = logger  # Rack uses this logger to pass to the request-scope and to log errors that make the app (Sinatra) crash. This logger is used for application-logs (created by us) and unforeseen errors.
#   env['rack.logger']      = logger  # this may lead to duplicated logs (Rack and Sinatra, both logging to the same logfile); probably unnecessary, especially after calling use Rack::CommonLogger
# end #before
