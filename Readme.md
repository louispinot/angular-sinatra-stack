## Getting Started ===========================================
* install npm  (brew install npm, sudo apt-get install npm)
* install [postgres](http://www.gotealeaf.com/blog/how-to-install-postgresql-on-a-mac):
  * Max OS X:
    * brew install postgres
    * initdb /usr/local/var/postgres
    * `pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start`
  * Debian/Ubunut:
    * sudo apt-get install postgresql postgresql-contrib libpq-dev
    * mkdir -p /var/postgres/compass  (you may have to chown the folder!)
    * sudo -i -u postgres createuser --interactive
    * createdb compass
    * sudo /etc/init.d/postgresql start
* install and configure R
  * download and install [R](http://cran.r-project.org/)
  * run `R` from terminal and install packages `install.packages('RPostgreSQL') install.packages('flexclust') install.packages('randomForest') install.packages('dplyr')`
  * note: Before being able to install R-packages, you may need to install an X11-server for your [Max OS X](http://xquartz.macosforge.org/landing/). You may have to install RPostgresSQL from source `install.packages('RPostgresSQL', type="source")`
* cd core.api
* set the environment you want to run `export RACK_ENV=local`
* bundle install
* create database `RACK_ENV=local rake db:create` then `rake db:migrate`
* ruby app.rb
* http://localhost:4567/

## Database  ===========================================
* Check if PostgreSQL database server is running:  `ps aux  |  grep postgres  |  grep -v grep`
* (Test-)Connect to your pSQL-server with pgAdmin3 (interfaced) or bash-client psql:  psql -h localhost -U rayo -c 'SELECT * FROM pg_catalog.pg_tables;' compass
* Stop PostgreSQL database server:  `pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log stop`

## Reset Database (-contents)
* alias yolodb="export RACK_ENV=local  &&  rake db:drop  &&  rake db:create  &&  rake db:migrate"
* export RACK_ENV=local  &&  bundle exec rake db:drop  &&  bundle exec rake db:create  &&  bundle exec rake db:migrate
* export RACK_ENV=local  &&  bundle exec rake db:rollback STEP=99  &&  bundle exec rake db:create  &&  bundle exec rake db:migrate
* (For completeness: There is another option: You could manually DROP all TABLEs and re-create and migrate the database.)

* For Production and Development database you may not be able to drop a database while other users are connected to it.
  * By default, AWS defines its database.yml file with a reconnect=true parameter
  * Thus, you may have to stop the respective Unicorn-server (SSH into the server(s)):  `/srv/www/webapp/shared/scripts/unicorn stop`
  * All other (not reconnecting) connections, you can drop with this query:
```ruby
      require 'pg'
      pg_conn = PG::Connection.new('compass-production.cg2fawjdedin.us-east-1.rds.amazonaws.com', 5432, nil, nil, 'compass', 'compass', '<PASSWORD>')
      pg_conn.exec( "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = 'TARGET_DB' AND pid <> pg_backend_pid();" )
      pg_conn.close
```

* Check database-servers directly with Postgres client psql:
  * PGPASSWORD='sjdhfkshfFHJWOuiewf789weiufewi'  psql -h 'compass-production.cg2fawjdedin.us-east-1.rds.amazonaws.com' -p '5432' -U compass 'compass'
  * PGPASSWORD='Vvhtq3Fh0w4C'  psql -h 'compass-beta.cg2fawjdedin.us-east-1.rds.amazonaws.com' -p '5432' -U compass 'compass'
  * psql -h localhost -U rayo compass

## Webserver ===========================================
## Simple Sinatra Server (core.api)
* Start Sinatra application with `ruby app.rb`

## NginX / Unicorn Server
* Install Nginx and Unicorn:
  * brew install nginx
  * gem install unicorn

* Configure NginX and Unicorn:
  * Unicorn configuration can be found in core.api/unicorn.rb in the repository
  * config.ru creates a Rack(up) file that is used by Unicorn to start a webserver serving our application. This file is also essential for our AWS Opsworks Rails-layer running with NginX/Unicorn.
  * NginX configuration can be found in one of these directories: /usr/local/etc/nginx, /usr/local/nginx/conf, /etc/nginx
    * vi /usr/local/etc/nginx/nginx.conf  (see also nginx.conf.example)
    * within HTTP-configuration add logs and connection to Unicorn-server:
```javascript
        access_log /var/log/nginx.access.log combined;
        error_log /var/log/nginx.error.log;
        # use the socket we configured in our unicorn.rb
        upstream unicorn_server {
          server unix:/Users/rayo/Development/CompassCore/tmp/sockets/unicorn.sock
              fail_timeout=0;
        }
```
    * Within Server-configuration add root-folder and proxy to Unicorn (Important Note: You have to remove/comment other locations with the same path "/"!)
```javascript
        root /Users/rayo/Development/CompassCore/core.api/public;
	      location / {
            try_files $uri @app;
        }
        location @app {
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header Host $http_host;
          proxy_redirect off;
          # pass to the upstream unicorn server mentioned above
          proxy_pass http://unicorn_server;
        }
```

* Start (and stop) servers, NginX and Unicorn:
  * Simply use the repository files: `sh start_server.sh` and `sh stop_server.sh`, or manually:
  * [[[ Note: Ignore the following list if you use the start_server/stop_server scripts! ]]] If you want to do it manually:
    * Change to your application directory (eg. cd /Users/rayo/Development/CompassCore/)
    * mkdir -p log;  mkdir -p tmp/pids;  mkdir -p tmp/sockets
    * unicorn -c unicorn.rb -E local -D
    * sudo nginx
    * ps aux  |  grep 'unicorn\|nginx\|postgres'  |  grep -v grep
    * http://localhost:8080/
    * Stop servers:
      * sudo nginx -s stop
      * cat ./tmp/pids/unicorn.pid | xargs sudo kill -QUIT
  * On Amazon's AWS:
    * Switch to the <application>/current/ folder and call:  `/srv/www/webapp/shared/scripts/unicorn start`
  * Bash call example for local testing in development-environment:
    * `sh stop_server.sh;  rm log/unicorn.std*;  sh start_server.sh development;  echo 'log/unicorn.stdout.log log/unicorn.stderr.log' | xargs tail -f`

* Webserver logs, NginX and Unicorn:
  * Find Unicorn / application logs here:
    * ./log/unicorn.stderr.log
  * Find NginX logs here:
    * /var/log/nginx.access.log
    * /usr/local/var/log/nginx/error.log
    * /tmp/nginx.access.log
    * /var/log/nginx/error.log
  * Find (brew) PostgreSQL-server log here:
    * /usr/local/var/postgres/server.log

* Troubleshoot:
  * If you get a 403 or 50X error and your NginX error-log (/var/log/nginx.error.log) shows a
    * "(13: Permission denied)" error (when trying to access the Unicorn socket), the NginX user ("nobody") may not be able to see the contents of the folder containing the Unicorn-socket.
    * "(60: Operation timed out)" error, there may be an application bug leading to load/execution times over 60 seconds. Check your Unicorn log in ./log/unicorn.stderr.log
    * "(2: No such file or directory)" error while connecting to the Unicorn upstream, the Unicorn-server may not be running or NginX upstream configuration is wrong. Check your Unicorn error-log in ./log/unicorn.stderr.log. Check your NginX-configuration.
    * "(61: Connection refused)" error while connecting to the Unicorn upstream, the NginX-server may look at the wrong place/directory for the Unicorn(-server)-socket. Check your NginX-configuration.
  * Your application does not work properly due to Unicorn errors (./log/unicorn.stderr.log):
    * ActiveRecord::ConnectionNotEstablished - ActiveRecord::ConnectionNotEstablished: Check correctness of config/database.yml file  OR  check your PostgreSQL-server log in /usr/local/var/postgres/server.log

## R code  ===========================================
As a prerequisite, you have to have installed R on your machine.
Then if you hit an error executing some R code, go to /analysis-r/cluster/ and check the .Rout file, which logs the execution of the R code and can tell you where it failed (for instance, hitting a missing R packages)

To install a package, open the R console (see article on Confluence) and run `install.packages('packageName')`.
For the RPostgreSQL package, you may get this error message: "package ‘RPostgreSQL’ is available as a source package but not as a binary"; In that case try `install.packages("RPostgreSQL", type="source")`.

## Testing  ===========================================
Run the test suite from the root directory and by running `bundle exec rake -f ./core.api/Rakefile`
