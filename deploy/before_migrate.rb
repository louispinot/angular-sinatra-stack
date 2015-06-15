# see Amazon documentation for chef deployment hooks:
# http://docs.aws.amazon.com/opsworks/latest/userguide/workingcookbook-extend-hooks.html
# before_migrate.rb runs after the Checkout stage is complete but before (Database-)Migrate.

app_env         = new_resource.environment["APP_ENV"]
gulp_path       = release_path + '/core.client/'


Chef::Log.info( 'Building (Compass Core) Angular-application files with Gulp in folder %s (APP_ENV=%s).' % [gulp_path, app_env] )

execute 'gulp-build-angular-app' do
  cwd gulp_path
  # quickfix installing Gulp locally - if it hasn't been installed before (globally)
  command 'npm install gulp;  gulp build'
  action :run
end #execute do

