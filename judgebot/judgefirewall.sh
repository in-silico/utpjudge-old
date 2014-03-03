#!/bin/sh

# Largely adapted from xdm's init script:
# Copyright 1998-2002, 2004, 2005 Branden Robinson <branden@debian.org>.
# Copyright 2006 Eugene Konev <ejka@imfi.kspu.ru>

### BEGIN INIT INFO
# Provides:          judgefirewall.sh
# Required-Start:
# Required-Stop:
# Should-Start:
# Should-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start/stop the firewall daemon for the UTPjudge.
### END INIT INFO

#
# If some data here is incorrect change it
#

USER="_utpjudge"
USER_ID=`id -u $USER`
LAN="eth0"

#/sbin/iptables -A OUTPUT -o lo -m owner --uid-owner $USER_ID -j DROP
#/sbin/iptables -t filter -A OUTPUT -p tcp -m owner --uid-owner $USER_ID -j DROP

start_firewall(){
  /sbin/iptables -A OUTPUT -o $LAN -m owner --uid-owner $USER_ID -j DROP
}

status_firewall(){
  /sbin/iptables -L
}

stop_firewall(){
  /sbin/iptables -D OUTPUT -o $LAN -m owner --uid-owner $USER_ID -j DROP
}

case $1 in
  start)
    start_firewall;
  ;;

  status)
    status_firewall;
  ;;

  stop)
    stop_firewall;
  ;;

  *)
    echo "Usage: $0 (start|stop|status)"
  ;;
esac
