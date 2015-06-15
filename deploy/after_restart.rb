# see Amazon documentation for chef deployment hooks:
# http://docs.aws.amazon.com/opsworks/latest/userguide/workingcookbook-extend-hooks.html

#QUICKFIX: commenting this; sometimes this does not seem to work if there is not enough time between stop and start...
#    ... has to be done manually for now
# -------------------------------------------------
# execute 'restart unicorn manually' do
#   cwd '/srv/www/webapp/current'
#   environment 'APP_ENV' => node['env']['APP_ENV'], 'RACK_ENV' => node['env']['APP_ENV']
#   # quickfix manually restarting Unicorn in order to reload settings, environment, and initializers
#   command '/srv/www/webapp/shared/scripts/unicorn stop;  /srv/www/webapp/shared/scripts/unicorn start'
#   action :run
# end #execute do


