#!/bin/sh
DEV="eth0"
VIP="10.0.0.1 10.0.0.2"

healthcheck() {
    for i in $VIP; do
	if [ -z "`ip addr show $DEV | grep $i`" ]; then
	    if [ "200" -ne "`curl -s -I 'http://$i/'` | head -n 1 | cut -f 2 -d ' '" ]; then
		CIP="$i"
		return 1
	    fi
	fi
    done
    return 0
}

ip_takeover() {
    MAC=`ip link show $DEV | egrep -o '([0-9a-f]{2}:){5}[0-9a-f]{2}' | head -n 1 | tr -d :`
    ip addr add $CIP/24 dev $DEV
    send arp $CIP $MAC 255.255.255.255 ffffffffffffffff
}

while healthcheck; do
    echo "health ok!"
    sleep 1
done

echo "fail over!"
ip takeover
