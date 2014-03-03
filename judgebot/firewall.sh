#!/bin/bash
#
# If some data here is incorrect change it
#

USER="_utpjudge"
USER_ID=`id -u $USER`
LAN="eth0"

/sbin/iptables -A OUTPUT -o $LAN -m owner --uid-owner $USER_ID -j DROP

#/sbin/iptables -A OUTPUT -o lo -m owner --uid-owner $USER_ID -j DROP

#/sbin/iptables -t filter -A OUTPUT -p tcp -m owner --uid-owner $USER_ID -j DROP
