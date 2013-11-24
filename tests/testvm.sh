#!/bin/sh

case "$0" in
	/*)
		base=`dirname $0`
		;;
	
	*)
		base=`pwd`/`dirname $0`
		;;
esac
                        
. $base/../scripts/localbuild/vm.inc

MACHINE=$1
HOST=$2

echo "Starting '$MACHINE'.."
startvm "$MACHINE" "$HOST"
echo "Started."

sleep 10

echo "Stopping '$MACHINE'.."
stopvm "$MACHINE" "$HOST"

echo "Stopped."
