#!/bin/bash
rm -f tmp/pids/server.pid

bundle check > /dev/null 2>&1 || bundle install --local

if [ "$#" == 0 ]
then
    #bundle exec rake db:migrate
    exec bundle exec rackup -p 3001
fi

exec $@
