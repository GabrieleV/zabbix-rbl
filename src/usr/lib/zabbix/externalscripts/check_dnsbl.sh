#!/bin/bash
#echo "S0=$0 S1=$1 S2=$2" > /tmp/debug
#set -x 
if [[ $# -ne 2 ]]; then
	echo "Usage: ./${0##*/} <hostname> <blacklist service>"
	exit 1
fi

# Retrieves A record for hostname ($1)
HOSTLOOKUP=$(host -t a $1)

# IP address validity check
if [[ ! ${HOSTLOOKUP##*[[:space:]]} =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
	echo "Could not resolve a valid IP for $1"
	exit 1
fi

# Converts resolved IP into reverse IP
REVIP=`sed -r 's/([0-9]+)\.([0-9]+)\.([0-9]+)\.([0-9]+)/\4.\3.\2.\1/' <<< ${HOSTLOOKUP##*[[:space:]]}`

# Performs the actual lookup against blacklists
#159.17.237.212.0spam.fusionzero.com has no A record
#Host 159.17.237.212.zen.spamhaus.org not found: 3(NXDOMAIN)
REPLY=$(host -W 2 -t a $REVIP.$2 2>&1)
if [[ $REPLY == *"has no A record"* || $REPLY == *"not found"*  ]]
then
	echo "0"
elif [[ $REPLY == *"connection timed out"* ]]
then
	echo "2"
else
	echo "1"
fi

exit 0
