#!/bin/sh

if test `uname -m` = 'sun4u' -a $SHELL != '/usr/xpg4/bin/sh'; then
	SHELL=/usr/xpg4/bin/sh
	export SHELL
	exec $SHELL $0 $*
fi

case "$0" in
	/*)
		base=`dirname $0`
		;;
	
	*)
		base=`pwd`/`dirname $0`
		;;
esac

. $base/env.inc                        
. $base/status.inc
. $base/config

print_usage( )
{
	echo "Usage: statuscli ( get | set STATUS | upload <file> )" 1>&2
	echo "       where STATUS is one of the OSB result states" 1>&2
	exit 2
}

case $# in
	0)
		echo "ERROR: too few arguments" 1>&2
		print_usage
		;;
	
	1)
		OP=$1
		if test "x$OP" != 'xget'; then
			echo "ERROR: unknown operation '$OP'" 1>&2
			print_usage
		fi
		;;
	
	2)
		OP=$1
		STATUS=$2
		if test "x$OP" = "xset"; then
			STATUS=$2
		else
		if test "x$OP" = "xupload"; then
			FILE=$2
		else
			echo "ERROR: unknown operation '$OP'" 1>&2
		fi
		fi
		;;
		
	*)
		echo "ERROR: unknown arguments" 1>&2
		print_usage
		;;
esac

guess_os

case $OP in
	get)
		get_status
		echo "Status on master:"
		echo "OSB_NAME: $OSB_NAME"
		echo "Architecture: $OSB_ARCH"
		echo "OSB Status: $OSB_STATUS"
		echo "Virtual manchine name: $OSB_VM_NAME"
		echo "Hostname: $OSB_HOST_NAME"
		get_git_version
		echo "Git revision: $OSB_GIT_VERSION"
		get_operations
		echo "Operations to perform: $OPERATIONS"
		;;
	
	set)
		set_status $STATUS
		get_status
		if test "x$STATUS" != "x$OSB_STATUS"; then
			echo "ERROR: Status could not be set to '$STATUS', is still '$OSB_STATUS'" 1>&2
			exit 1
		fi
		echo "Status set to $STATUS."
		;;

	upload)
		get_status
		upload_file $FILE
		;;
		
	*)
		echo "ERROR: Unknown operation $OP" 1>&2
		exit 1
		;;
esac

exit 0
		
