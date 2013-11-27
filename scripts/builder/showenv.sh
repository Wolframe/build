#!/bin/sh

case "$0" in
	/*)
		base=`dirname $0`
		;;
	
	*)
		base=`pwd`/`dirname $0`
		;;
esac
                        
. $base/env.inc

guess_os

echo "Architecture: $ARCH"
echo "Operating System: $PLATFORM"
echo "OS Version: $OS_MAJOR_VERSION.$OS_MINOR_VERSION"
if test $PLATFORM = "LINUX"; then
	echo "Distribution: $LINUX_DIST"
	echo "Linux version: $LINUX_REV"
fi
