#!/bin/bash

consul lock -n=1 locks/consul "/bin/bash -c \" 
    sleep 5; 
    /usr/local/bin/consul-wait-for-leader.sh || exit 1; 
    bash -c 'sleep 2; systemctl restart consul' & 
\""

exit 0
