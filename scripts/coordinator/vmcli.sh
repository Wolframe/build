#!/bin/sh

case "$0" in
	/*)
		base=`dirname $0`
		;;
	
	*)
		base=`pwd`/`dirname $0`
		;;
esac
                        
. $base/vm.inc

if test $# -ne 3; then
	if test $# -ne 1 -o "x$1" != "xlist"; then
		echo "Usage: vmcli <VM machine> <network host> ( start | stop | status )" 1>&2
		echo "       vmcli list" 1>&2
		exit 2
	fi
	OP=$1
else
	MACHINE=$1
	HOST=$2
	OP=$3
fi

case $OP in
	start)
		echo "Starting '$MACHINE'.."
		startvm "$MACHINE" "$HOST"
		echo "Started."
		;;
	
	stop)
		echo "Stopping '$MACHINE'.."
		stopvm "$MACHINE" "$HOST"
		echo "Stopped."
		;;
	
	status)
		isalive "$HOST"
		if test $RES -eq 0; then
			echo "Is not running.."
			exit 1
		else
			echo "Is running.."
			exit 0
		fi
		;;
	
	list)
		cut -f4-5 $base/../../data/manual_results
		;;
	*)
		echo "ERROR: Unknown operation $OP" 1>&2
		;;
esac

exit 0

