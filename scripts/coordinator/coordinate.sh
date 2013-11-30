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
		startvm "$OSB_VM_NAME" "$OSB_HOST_NAME"
		get_next_status "scheduled"
		NOF_VMS_RUNNING=`expr $NOF_VMS_RUNNING + 1`
	done
}

terminate_tasks( )
{
	TERMINATE_STATUS=$1
	FINI_STATUS=`echo $TERMINATE_STATUS | tr -d '*'`
	get_first_status $TERMINATE_STATUS
	while test "x$OSB_NAME" != "x"; do
		echo "Terminating builder for $OSB_NAME $OSB_ARCH.."
		stopvm "$OSB_VM_NAME" "$OSB_HOST_NAME"
		set_status "$OSB_NAME" "$OSB_ARCH" "$FINI_STATUS"
		get_next_status $TERMINATE_STATUS
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

exit 0
