startvm( )
{
	VBoxManage startvm --type headless "$1" 2>&1 >/dev/null

	waitforreadyvm "$1" "$2"
}

isalive( )
{
	ping -q -c 5 $1 >/dev/null 2>&1
	if test $? -ne 0; then
		RES=0
	else
		PACKETS=`ping -q -c 5 $1 | grep 'received' | awk -F',' '{ print $2}' | awk '{ print $1}'`
		if test $PACKETS -eq 5; then
			RES=1
		else
			RES=0
		fi
	fi
}

waitforreadyvm( )
{
	VBoxManage list runningvms | grep "$1" 2>&1 >/dev/null
	RET=$?
	until [ $RET -eq 0 ]; do
		VBoxManage list runningvms | grep "\"$1\"" 2>&1 >/dev/null
		RET=$?
		sleep 5
	done

	isalive "$2"
	until [ $RES -eq 1 ]; do
		isalive "$2"
		sleep 5
	done
}

waitfortermvm( )
{
	VBoxManage list runningvms | grep "$1" 2>&1 >/dev/null
	RET=$?
	until [ $RET -eq 1 ]; do
		VBoxManage list runningvms | grep "\"$1\"" 2>&1 >/dev/null
		RET=$?
		sleep 5
	done
}

stopvm( )
{
	VBoxManage controlvm "$1" acpipowerbutton 2>&1 >/dev/null

	waitfortermvm "$1" "$2"
}

nof_running_vms( )
{
	RES=`VBoxManage list runningvms | wc -l`
}
