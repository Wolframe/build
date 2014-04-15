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
		case "$OSB_VM_NAME" in
			PHYS*)
				# physical machine, not-virtual, ignore when
				# counting and handling virtual machines
				get_next_status "scheduled"
				;;
			
			*)
				echo "Scheduling new builder for $OSB_NAME $OSB_ARCH.." >>$LOGFILE
				set_status "$OSB_NAME" "$OSB_ARCH" "building"
				startvm "$OSB_VM_NAME" "$OSB_HOST_NAME"
				get_next_status "scheduled"
				NOF_VMS_RUNNING=`expr $NOF_VMS_RUNNING + 1`
				;;
		esac
	done
}

schedule_tasks_real( )
{
	get_first_status "scheduled"
	while test "x$OSB_NAME" != "x"; do
		case "$OSB_VM_NAME" in
			PHYS*)
				echo "Checking if real machine $OSB_NAME $OSB_ARCH is up.." >>$LOGFILE
				isalive "$OSB_HOST_NAME"
				if test $RES = 0; then
					echo "$OSB_HOST_NAME is not up, not scheduling, setting to failed.." >>$LOGFILE
					set_status "$OSB_NAME" "$OSB_ARCH" "skip"
				else
					echo "Scheduling real machine $OSB_NAME $OSB_ARCH for building.." >>$LOGFILE
					set_status "$OSB_NAME" "$OSB_ARCH" "building"
				fi
				get_next_status "scheduled"
				;;
			
			*)
				get_next_status "scheduled"
				;;
		esac
	done
}

terminate_tasks( )
{
	TERMINATE_STATUS=$1
	FINI_STATUS=`echo $TERMINATE_STATUS | tr -d '*'`
	get_first_status $TERMINATE_STATUS
	while test "x$OSB_NAME" != "x"; do
		case "$OSB_VM_NAME" in
			PHYS*)
				# just collect results and toggle state, physical
				# machine stays up
				echo "Builder on real machine $OSB_NAME $OSB_ARCH finished building.."
				set_status "$OSB_NAME" "$OSB_ARCH" "$FINI_STATUS"
				get_next_status $TERMINATE_STATUS
				;;
			
			*)
				echo "Terminating builder for $OSB_NAME $OSB_ARCH.." >>$LOGFILE
				stopvm "$OSB_VM_NAME" "$OSB_HOST_NAME"
				set_status "$OSB_NAME" "$OSB_ARCH" "$FINI_STATUS"
				get_next_status $TERMINATE_STATUS
		esac
	done
}

LOGFILE=$base/../../logs/coordinator.log

# already running?
LOCKFILE=$base/../../logs/coordinator.lock
if test -f $LOCKFILE; then
	echo "WARNING: A coordinator is already running.. terminating this instance." >>$LOGFILE
	exit 0
fi
touch $LOCKFILE

# first see if we have scheduled entries
echo "Checking if tasks are scheduled.." >>$LOGFILE
get_first_status "scheduled"
has_tasks=0
while test "x$OSB_NAME" != "x"; do
	get_next_status $STATUS
	has_tasks=1
done

if test $has_tasks -eq 0; then
	echo "No new tasks scheduled." >>$LOGFILE
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
echo "Currently $NOF_VMS_RUNNING builders are running." >>$LOGFILE
if test $has_tasks -eq 1; then
	if test $NOF_VMS_RUNNING -ge $MAX_VMS; then
		echo "All builder slots occupied, cannot start new builders at the moment." >>$LOGFILE
	else
		schedule_tasks
	fi
	schedule_tasks_real
fi

# remove lock file
rm -f $LOCKFILE

exit 0
