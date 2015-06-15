#!/bin/bash

echo "Stopping NginX with Unicorn webserver. No other (NginX or Unicorn) processes should be running:"

sudo nginx -s stop
cat ./tmp/pids/unicorn.pid | xargs sudo kill -QUIT
# NOT stopping PostgreSQL-server, by default (maybe, you want to check something with pdAdmin?)
# pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log stop

sleep 1
ps aux  |  grep 'unicorn\|nginx'  |  grep -v grep


