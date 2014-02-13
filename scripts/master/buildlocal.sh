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
. $base/status.inc

schedule_tasks( )
{
	SCHEDULE_STATUS=$1
	get_first_status $SCHEDULE_STATUS
	while test "x$OSB_NAME" != "x"; do
		echo "Scheduling task for platform '$OSB_NAME' arch '$OSB_ARCH'."
		set_status "$OSB_NAME" "$OSB_ARCH" "scheduled"
		get_next_status $SCHEDULE_STATUS
	done
}

if test $DISABLE_LOCAL_BUILDS -eq 1; then
	echo "Local builds disabled."
	exit 0
fi

cd $OSC_HOME/$OSC_PROJECT
osc up
OSC_REVISION=`osc info | grep Revision | cut -f 2 -d ' '`

if test "x$OSC_REVISION" = "x"; then
	echo "OSC revision cannot be determined. Check network or OSC workspace for errors!" 1>&2
	exit 1
fi

LOCAL_BUILD_OSC_VERSION_FILE=$CACHE_DIR/LOCAL_BUILD_OSC_VERSION

if test -f $LOCAL_BUILD_OSC_VERSION_FILE; then
	LOCAL_BUILD_OSC_VERSION=`cat $LOCAL_BUILD_OSC_VERSION_FILE`
else
	LOCAL_BUILD_OSC_VERSION=0
fi

# nothing to do or already scheduled
if test $OSC_REVISION -le $LOCAL_BUILD_OSC_VERSION; then
	echo "Nothing to be done. Local build version is currently '$LOCAL_BUILD_OSC_VERSION'."
	exit 0
fi

echo "Scheduling local builds for project '$OSC_PROJECT'.."

REPO_CACHE=$CACHE_DIR/repo.cache
archs=`cat $REPO_CACHE | cut -f 2 | sort | uniq`
platforms=`cat $REPO_CACHE | cut -f 1 | sort | uniq`

# check first if we are currently building or already
# scheduled (in the local project)
# TODO: do this globally, but for this we have to configure more than
# one "side-kick-project" for coordination..
get_first_status
schedule=1
while test "x$OSB_NAME" != "x"; do
	if test $OSB_STATUS != "succeeded" -a $OSB_STATUS != "failed" -a $OSB_STATUS != 'disabled'; then
		echo "Not scheduling now, platform '$OSB_NAME', arch '$OSB_ARCH' is in state '$OSB_STATUS'.."
		schedule=0
	fi
	get_next_status
done

if test $schedule -eq 0; then
	exit
fi

# turn on scheduling on all non-disabled platforms
schedule_tasks "succeeded"
schedule_tasks "failed"

echo "$OSC_REVISION" > $LOCAL_BUILD_OSC_VERSION_FILE

echo "Done."
