#!/bin/sh

if test `uname -m` = 'sun4u' -a $SHELL != '/usr/xpg4/bin/sh'; then
	SHELL=/usr/xpg4/bin/sh
	export SHELL
	exec $SHELL $0 $*
	exit $?
fi

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
. $base/status.inc

global_lock

guess_os

cd $base

get_status
get_git_version

# upload build artifact to the master, depending on the platform different
# artifacts lie around in different places :-)
upload_file $LOCAL_BUILD_DIR/build.log
case $PLATFORM.$LINUX_DIST in
	LINUX.redhat*)
		if test "x$ARCH" = "xx86"; then
			ARCH="i386"
		fi
		for file in /root/rpmbuild/RPMS/$ARCH/$PROJECT_PREFIX*.rpm; do
			upload_file $file
		done
		;;
	
	LINUX.slackware*)
		if test "x$ARCH" = "xx86"; then
			ARCH="i686"
		fi
		for file in /root/slackbuild/PKGS/$ARCH/$PROJECT_PREFIX*.tgz; do
			upload_file $file
		done
		;;
		
	LINUX.arch*)
		if test "x$ARCH" = "xx86"; then
			ARCH="i686"
		fi
		for file in /root/archbuild/PKGS/$ARCH/$PROJECT_PREFIX*.tar.xz; do
			upload_file $file
		done
		;;
		
	FREEBSD*)
		if test "x$ARCH" = "xx86"; then
			ARCH="i686"
		fi
		for file in /root/bsdbuild/PKGS/$ARCH/$PROJECT_PREFIX*.t[xg]z; do
			upload_file $file
		done
		;;

	NETBSD*)
		if test "x$ARCH" = "xx86"; then
			ARCH="i686"
		fi
		for file in $HOME/bsdbuild/PKGS/$ARCH/$PROJECT_PREFIX*.t[xg]z; do
			upload_file $file
		done
		;;
	
	SUNOS*)
		for file in $HOME/solarisbuild/PKGS/$ARCH/$PROJECT_PREFIX*.pkg.Z; do
			upload_file $file
		done
		;;

	*)
		echo "ERROR: no clue how to upload artifacts on '$PLATFORM', '$LINUX_DIST'"
		;;
esac

global_unlock
