#!/bin/bash

#create default nw and epg
netctl net create default-net --subnet=20.1.1.0/24 --gateway=20.1.1.254


#create poc nw and epg
netctl net create poc-net --subnet=21.1.1.0/24 --gateway=21.1.1.254
netctl group create poc-net poc-epg
