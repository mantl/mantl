#!/bin/bash

set -x 

token=$1

if [ -n "${token}" ]; then
  cargs="-token=${token}"
fi

consul lock ${cargs} -n=1 locks/consul "/bin/bash -x -c \" 
    sleep 5; 
    /usr/local/bin/consul-wait-for-leader.sh ${token} || exit 1; 
    bash -c 'sleep 2 && systemctl restart consul' & 
\""

# Give 'sleep 2 && systemctl restart consul' time to execute before exiting
sleep 5

exit 0
