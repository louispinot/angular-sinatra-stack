#!/bin/bash

rack_environment=${1:-'local'}

echo "Starting PostgreSQL-server and NginX with Unicorn webserver in $rack_environment environment."

mkdir -p log;  mkdir -p tmp/pids;  mkdir -p tmp/sockets
pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start  2>&1  |  grep -v 'pg_ctl: another server might be running'  |  awk '{print "PostgreSQL-server: "$0;}'
bundle install  |  tail -n 2
unicorn -c unicorn.rb -E $rack_environment -D
sudo nginx
ps aux  |  grep 'unicorn\|nginx\|postgres'  |  grep -v grep

echo "If you see both, NginX, Unicorn, and Postgres processes running, open your browser and go to http://localhost:8080/."



