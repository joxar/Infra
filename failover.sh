#!/bin/bash
VIP="10.0.0.1"
DEV="eth0"

healthcheck() {
  ping -c 1 -W 1 $VIP >/dev/null
  return $?
}

ip_takeover() {
  MAC=`ip link show $DEV | egrep -o '([0-9a-f]{2}:){5}[0-9a-f]{2}' | head -n 1 | tr -d :`
  ip addr add $VIP/24 dev $DEV
  send_arp $VIP $MAC 255.255.255.255 ffffffffffffffff
}

while healthcheck; do
  echo "health ok!"
  sleep 1
done
echo "fail over"
ip_takeover

