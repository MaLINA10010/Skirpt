#!/bin/bash

# Storm IP (protected)
STORM_IP=(185.71.66.178/32)
# Client IP
LOCAL_IP="91.132.228.175"
# StormWall remote tunnel IP
REMOTE_IP="193.84.78.144"
# StormWall remote IP inside tunnel
REMOTE_INTERNAL_IP="10.202.0.146"
# Routing table number
N=1080
# Tunnel device
TUN_DEV=storm1080

case "$1" in
    start)
        ip tunnel add ${TUN_DEV} mode gre remote ${REMOTE_IP} local ${LOCAL_IP} ttl 64
        ip link set ${TUN_DEV} up
        for index in ${!STORM_IP[*]}; do
          ip addr add ${STORM_IP[$index]} peer ${REMOTE_INTERNAL_IP} dev ${TUN_DEV}
        done

        ip route add default via ${REMOTE_INTERNAL_IP} dev ${TUN_DEV} tab ${N}
        for index in ${!STORM_IP[*]}; do
          ip rule add from ${STORM_IP[$index]} tab ${N} prio 3
        done

        ;;

    stop)
        ip route del default via ${REMOTE_INTERNAL_IP} dev ${TUN_DEV} tab ${N}
        ip link set ${TUN_DEV} down
        for index in ${!STORM_IP[*]}; do
          ip rule del from ${STORM_IP[$index]} tab ${N}
        done

        ip tunnel del ${TUN_DEV}

        ;;
    *)
        echo "Usage: $0 {start|stop}"
        ;;
esac