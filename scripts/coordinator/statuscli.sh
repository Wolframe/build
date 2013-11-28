#!/bin/sh

case "$0" in
	/*)
		base=`dirname $0`
		;;
	
	*)
		base=`pwd`/`dirname $0`
		;;
esac
                        
. $base/status.inc
. $base/config

print_usage( )
{
	echo "Usage: statuscli ( list | get <platform> <arch> | set <platform> <arch> STATUS )" 1>&2
	echo "       where STATUS is one of the OSB result states" 1>&2
	echo "       and platform arch are OSB tokens listed by 'list'" 1>&2
	exit 2
}

case $# in
	0)
		echo "ERROR: too few arguments" 1>&2
		print_usage
		;;
	
	1)
		OP=$1
		if test "x$OP" != 'xlist'; then
			echo "ERROR: unknown operation '$OP'" 1>&2
			print_usage
		fi
		;;
	
	3|4)
		OP=$1
		if test "x$OP" = "xget"; then
			PLATFORM=$2
			ARCH=$3
		else
		if test "x$OP" = "xset"; then
			PLATFORM=$2
			ARCH=$3
			STATUS=$4
		else
			echo "ERROR: unknown operation '$OP'" 1>&2
		fi
		fi
		;;
		
	*)
		echo "ERROR: unknown number of arguments ($#)" 1>&2
		print_usage
		;;
esac

print_status( )
{
	echo "Status on master:"
	echo "OSB_NAME: $OSB_NAME"
	echo "Architecture: $OSB_ARCH"
	echo "OSB Status: $OSB_STATUS"
	echo "Virtual manchine name: $OSB_VM_NAME"
	echo "Hostname: $OSB_HOST_NAME"
}

case $OP in
	list)
		get_first_status
		while test "x$OSB_NAME" != 'x'; do
			print_status
			get_next_status
		done
		;;
		
	get)
		get_status $PLATFORM $ARCH
		print_status
		;;
	
	set)
		set_status $PLATFORM $ARCH $STATUS
		get_status $PLATFORM $ARCH
		if test "x$STATUS" != "x$OSB_STATUS"; then
			echo "ERROR: Status could not be set to '$STATUS', is still '$OSB_STATUS'" 1>&2
			exit 1
		fi
		echo "Status set to $STATUS."
		;;

	*)
		echo "ERROR: Unknown operation $OP" 1>&2
		exit 1
		;;
esac

exit 0
		
