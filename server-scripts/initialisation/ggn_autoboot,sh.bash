#!/bin/bash
# Author: your name here
#
# /etc/init.d/my_maintenance
#
### BEGIN INIT INFO
# Provides:          my_maintenance
# Required-Start:    network
# Should-Start:      $null
# Required-Stop:     xdm
# Should-Stop:	     $null
# Default-Start:     5
# Default-Stop:      5
# Short-Description: Runs various maintenance scripts.
# Description:       Not actually a service at all.
### END INIT INFO

. /etc/rc.status

rc_reset

case "$1" in
   start)
     # use colour for ease of spotting
      echo -e "\E[36mRunning $0 (start)...\E[0m";
      /etc/init.d/my_maintenance.d/start
      echo -e "\E[36mDone $0 \E[0m";
   ;;
   stop)

      echo -e "\E[36mRunning $0 (stop)...\E[0m";
      /etc/init.d/my_maintenance.d/stop
      echo -e "\E[36mDone $0 \E[0m";
   ;;
   restart)
      $0 stop
      $0 start
      rc_status
      ;;
   *)
      echo "Usage $0 (start|stop|restart)"
      exit 1; 
      ;;
esac 

rc_exit