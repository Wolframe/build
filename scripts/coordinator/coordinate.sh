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
. $base/vm.inc
. $base/status.inc

schedule_tasks( )
{
	get_first_status "scheduled"
	while test "x$OSB_NAME" != "x" -a $NOF_VMS_RUNNING -lt $MAX_VMS; do
		echo "Scheduling new builder for $OSB_NAME $OSB_ARCH.."
		set_status "$OSB_NAME" "$OSB_ARCH" "building"
#		startvm "$OSB_VM_NAME" "$OSB_HOST_NAME"
		get_next_status "scheduled"
		NOF_VMS_RUNNING=`expr $NOF_VMS_RUNNING + 1`
	done
}

terminate_tasks( )
{
	STATUS=$1
	FINI_STATUS=`echo $STATUS | tr -d '*'`
	get_first_status $STATUS
	while test "x$OSB_NAME" != "x"; do
		echo "Terminating builder for $OSB_NAME $OSB_ARCH.."
		stopvm "$OSB_VM_NAME" "$OSB_HOST_NAME"
		set_status "$OSB_NAME" "$OSB_ARCH" "$FINI_STATUS"
		get_next_status $STATUS
	done
}

# first see if we have scheduled entries
echo "Checking if tasks are scheduled.."
get_first_status "scheduled"
has_tasks=0
while test "x$OSB_NAME" != "x"; do
	get_next_status $STATUS
	has_tasks=1
done

if test $has_tasks -eq 0; then
	echo "No new tasks scheduled."
fi

# check for terminated builders, stop the VMs if they are
# finished (succeeded* or failed*), mark the status as final
# (succeeded or failed).
terminate_tasks "succeeded*"
terminate_tasks "failed*"

# check how many builders are currently running, if we
# are over the limit we can't start more
nof_running_vms
NOF_VMS_RUNNING=$RES
echo "Currently $NOF_VMS_RUNNING builders are running."
if test $NOF_VMS_RUNNING -ge $MAX_VMS; then
	echo "All builder slots occupied, cannot start new builders at the moment."
else
	schedule_tasks
fi


exit

# we are building now, indicate status
set_status "building*"

echo "Updating project '$OSC_PROJECT' from git repository.."
# building always current master, update it
cd $LOCAL_BUILD_DIR
git pull

guess_os

echo "Building for:"
echo "  Architecture: $ARCH"
echo "  Operating System: $PLATFORM"
echo "  OS Version: $OS_MAJOR_VERSION.$OS_MINOR_VERSION"
if test $PLATFORM = "LINUX"; then
	echo "  Distribution: $LINUX_DIST"
	echo "  OSB_PLATFORM: $OSB_PLATFORM"
fi

# force usage of ccache
case $PLATFORM.$LINUX_DIST in
	LINUX.redhat*)
		. /etc/profile.d/ccache.sh
		;;
	*)
esac
echo "PATH is: $PATH"
TYPE_CC=`type gcc`
TYPE_CXX=`type g++`
echo "CC: $TYPE_CC"
echo "CXX: $TYPE_CXX"
echo "CCACHE_DIR: $CCACHE_DIR"

# depending on the packaging system we call the correct local build script
echo "Started local build script.."
case $PLATFORM.$LINUX_DIST in
	LINUX.redhat*)
		export OSB_PLATFORM
		packaging/redhat/buildlocal.sh >build.log 2>&1
		RET=$?
		;;
		
	*)
		echo "ERROR: no clue how to build on '$PLATFORM', '$LINUX_DIST'"
		;;
esac

# upload build artifact to the master, depending on the platform different
# artifacts lie around in different places :-)
upload_file $LOCAL_BUILD_DIR/build.log
case $PLATFORM.$LINUX_DIST in
	LINUX.redhat*)
		for file in $HOME/rpmbuild/RPMS/x86_64/$PROJECT_PREFIX*.rpm; do
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
