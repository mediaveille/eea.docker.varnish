#!/bin/bash

source /etc/environment

IPS_1=`cat /etc/varnish/hosts.backends`
python3 /add_backends.py hosts
IPS_2=`cat /etc/varnish/hosts.backends`

if [ "$IPS_1" != "$IPS_2" ]; then
  echo "HOST backends changed: $IPS_2"
  reload
fi
