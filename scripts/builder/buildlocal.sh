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

# set pathes on some platforms
case $PLATFORM.$LINUX_DIST in
	NETBSD*)
		PATH=/usr/pkg/bin:/usr/pkg/sbin:$PATH
		export PATH
		;;
	FREEBSD*)
		PATH=/usr/local/bin:/usr/local/sbin:/usr/sbin:$PATH
		export PATH
		;;
	SUNOS*)
		TERM=vt220
		PATH=/opt/csw/bin:/usr/ccs/bin:/usr/bin:/bin:/usr/local/bin:/opt/csw/sbin:/usr/sbin:/sbin
		LD_LIBRARY_PATH=/opt/csw/lib:/opt/csw/postgresql/lib
		export TERM PATH LD_LIBRARY_PATH
		;;
	LINUX.arch*)
		# add Intel compiler to the path if we have one (Linux Arch VMs only)
		if test -x /etc/profile.d/intel_compilers.sh; then
			. /etc/profile.d/intel_compilers.sh
		fi
		;;
	LINUX.redhat)
		# add Intel compiler to the path if we have one (Centos VMs with Intel CC only)
		if test -f /opt/intel/bin/iccvars.sh; then
			MACHINE_ARCH=`uname -m`
			if test "$MACHINE_ARCH" = "x86_64"; then
				ICC_ARCH="intel64"
			else
				if test "$MACHINE_ARCH" = "i686"; then
					ICC_ARCH="ia32"
				else
					print "ERROR: Unknown Intel architecture $MACHIN_ARCH!"
					global_unlock
					exit 1
				fi
			fi
			. /opt/intel/bin/iccvars.sh $ICC_ARCH
		fi
		;;
	*)
esac

# change to a unique directory!
cd $base

# first see, if we really have something to do, otherwise we were
# either awakened by the coordinator and he will shut us down again
# or the user is doing something manually on the virtual machine
get_status
get_git_version
echo "Building for:"
echo "  Architecture: $ARCH"
echo "  Operating System: $PLATFORM"
echo "  OS Version: $OS_MAJOR_VERSION.$OS_MINOR_VERSION"
echo "  Git revision: $OSB_GIT_VERSION"
if test $PLATFORM = "LINUX"; then
	echo "  Distribution: $LINUX_DIST"
	echo "  OSB_PLATFORM: $OSB_PLATFORM"
fi
echo "  OSB status is: $OSB_STATUS (must be building!)"
echo "  Current working dir is: $PWD"
echo "  PID is: $$"
if test "x$OSB_STATUS" != 'xbuilding'; then
	global_unlock
	exit 0
fi

# check if we have to update ourselves, restart
# oursevles if we update (sh is picky when the
# underlying source file of a running script is
# changed at runtime!)
REMOTE_SHA=`git ls-remote origin -h refs/heads/master | cut -f 1`
OUR_SHA=`git rev-list HEAD | head -n 1`
echo "We are at revision $OUR_SHA"
echo "Remote revision is $REMOTE_SHA"
if test "x$OUR_SHA" != "x$REMOTE_SHA"; then
	global_unlock
	git pull && $base/$(basename $0) && exit
fi

# force usage of ccache
case $PLATFORM.$LINUX_DIST in
	LINUX.redhat*)
		. /etc/profile.d/ccache.sh
		;;
	
	LINUX.debian*)
		CCACHE_DIR=/root/.ccache
		PATH=/usr/lib/ccache/:${PATH}
		export PATH CCACHE_DIR
		;;
	
	NETBSD*)
		CCACHE_DIR=/root/.ccache
		export CCACHE_DIR
		;;
	*)
esac
echo "PATH is: $PATH"
TYPE_CC=`type gcc`
TYPE_CXX=`type g++`
echo "CC: $TYPE_CC"
echo "CXX: $TYPE_CXX"
echo "CCACHE_DIR: $CCACHE_DIR"

# we are building now, indicate status
set_status "building*"

echo "Updating project '$OSC_PROJECT' from git repository.."
# building always current master, update it, then go to
# the revision we are currently supposed to build
cd $LOCAL_BUILD_DIR
git fetch origin
git reset --hard origin/master
git checkout $OSB_GIT_VERSION

# depending on the packaging system we call the correct local build script
echo "Started local build script.."
case $PLATFORM.$LINUX_DIST in
	LINUX.redhat*)
		export OSB_PLATFORM
		packaging/redhat/buildlocal.sh >build.log 2>&1
		RET=$?
		;;
		
	LINUX.slackware*)
		packaging/slackware/buildlocal.sh >build.log 2>&1
		RET=$?
		;;

	LINUX.arch*)
		packaging/archlinux/buildlocal.sh >build.log 2>&1
		RET=$?
		;;

	LINUX.debian*)
		if test ! -L debian; then
			rm debian
			ln -s packaging/debian debian
		fi
		dpkg-buildpackage -us -uc >build.log 2>&1
		RET=$?
		;;
	
	FREEBSD*)
		packaging/freebsd/buildlocal.sh >build.log 2>&1
		RET=$?
		;;
	
	NETBSD*)
		packaging/netbsd/buildlocal.sh >build.log 2>&1
		RET=$?
		;;
	
	SUNOS*)
		packaging/solaris/buildlocal.sh >build.log 2>&1
		RET=$?
		;;
			
	*)
		echo "ERROR: no clue how to build on '$PLATFORM', '$LINUX_DIST'"
		RET=1
		;;
esac

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
	
	LINUX.debian*)
		for file in $LOCAL_BUILD_DIR/../$PROJECT_PREFIX*.deb; do
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

# toggle status on master, we can be 'succeeded*' or 'failed*' (the star is
# the temporary state as seen by the builder, the coordinator has to ACK first
# in order to get to the final 'succeeded' and 'failed' states)
if test $RET -eq 0; then
	set_status "succeeded*"
	echo "Done (succeeded)."
else
	set_status "failed*"
	echo "Done (failed)."
fi

global_unlock
