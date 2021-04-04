#!/bin/bash
HOST=$1
USERNAME=$2
PASSWORD=$3
PEER_NAME=$4
PEER_FIELD_NAME=$5
API_CALL="/routing/bgp/peer/print\n?name=$PEER_NAME\n"
API_ROS_COMMAND="/home/zabbix/externalscripts/apiros.py"

PEER_FIELD=$(echo -e "$API_CALL" | $API_ROS_COMMAND "$HOST" "$USERNAME" "$PASSWORD" | grep "$PEER_FIELD_NAME" | cut -d "=" -f 3)

if [ "$PEER_FIELD_NAME" == "state" ]; then
	if [ "$PEER_FIELD" == "established" ]; then
		echo 3

	elif [ "$PEER_FIELD" == "active" ]; then
		echo 2

	elif [ "$PEER_FIELD" == "opensent" ] || [ "$PEER_FIELD" == "openconfirm" ]; then
		echo 1

	elif [ "$PEER_FIELD" == "idle" ]; then
		echo 0
	else
		echo
	fi
elif [ "$PEER_FIELD_NAME" == "uptime" ]; then
	DAYS=$(echo -e "$PEER_FIELD" | egrep -o '[0-9]+d' | tr -d 'd')
	DAYS=${DAYS:-0}

	HOURS=$(echo -e "$PEER_FIELD" | egrep -o '[0-9]+h' | tr -d 'h')
	HOURS=${HOURS:-0}

	MINUTES=$(echo -e "$PEER_FIELD" | egrep -o '[0-9]+m' | tr -d 'm')
	MINUTES=${MINUTES:-0}

	SECONDS=$(echo -e "$PEER_FIELD" | egrep -o '[0-9]+s' | tr -d 's')
	SECONDS=${SECONDS:-0}

	echo "$DAYS $HOURS $MINUTES $SECONDS"

	TOTAL_SECONDS=$(echo "$DAYS * 86400 + $HOURS * 3600 + $MINUTES * 60 + $SECONDS" | bc)

	echo $TOTAL_SECONDS
else
	echo "$FIELD_NAME not supporting"
fi
