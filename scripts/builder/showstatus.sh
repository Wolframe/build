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

get_status

echo "Status on master:"
echo "OSB_NAME: $OSB_NAME"
echo "Architecture: $OSB_ARCH"
echo "OSB Status: $OSB_STATUS"
echo "Virtual manchine name: $OSB_VM_NAME"
echo "Hostname: $OSB_HOST_NAME"

