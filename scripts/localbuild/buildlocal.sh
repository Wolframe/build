#!/bin/sh

case "$0" in
	/*)
		base=`dirname $0`
		;;
	
	*)
		base=`pwd`/`dirname $0`
		;;
esac
                        
. $base/config
. $base/env.inc

cd $LOCAL_BUILD_DIR
git pull

guess_os

echo "Architecture: $ARCH"
echo "Operating System: $PLATFORM"
echo "OS Version: $OS_MAJOR_VERSION.$OS_MINOR_VERSION"
if test $PLATFORM = "LINUX"; then
        echo "Distribution: $LINUX_DIST"
fi

echo "Done."
