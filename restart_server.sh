#!/bin/bash

source stop_server.sh "$@"
rm log/unicorn.std*
source start_server.sh "$@"
echo 'log/unicorn.stdout.log log/unicorn.stderr.log'  |  xargs tail -f


