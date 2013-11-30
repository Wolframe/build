get_first_status( )
{
	STATUS=$1

	cat $base/../../data/manual_results | tr -s ' ' '_' >/tmp/build2.$$

	get_next_status $STATUS
}

get_next_status( )
{
	STATUS=$1

	read -r OSB_NAME OSB_ARCH OSB_STATUS _VM_NAME OSB_HOST_NAME </tmp/build2.$$
	OSB_VM_NAME=`echo $_VM_NAME | tr -s '_' ' ' | tr -d \"`

	if test "x$OSB_NAME" = "x"; then
		rm /tmp/build2.$$
	else
		sed '1d' /tmp/build2.$$ >/tmp/build3.$$
		mv -f /tmp/build3.$$ /tmp/build2.$$

		if test "x$STATUS" != "x" -a "x$STATUS" != "x$OSB_STATUS"; then
			get_next_status $STATUS
		fi
	fi
}

# get current data and status for this builder
get_status( )
{
	PLATFORM=$1
	ARCH=$2

	cat $base/../../data/manual_results | tr -s ' ' '_' >/tmp/build.$$
	while read -r _NAME _ARCH _STATUS _VM_NAME _HOST_NAME; do
		if test "x$PLATFORM" = "x$_NAME" -a "x$ARCH" = "x$_ARCH"; then
			OSB_NAME=$_NAME
			OSB_ARCH=$_ARCH
			OSB_STATUS=$_STATUS
			OSB_VM_NAME=`echo $_VM_NAME | tr -s '_' ' ' | tr -d \"`
			OSB_HOST_NAME=$_HOST_NAME
		fi
	done </tmp/build.$$

	rm -f /tmp/build.$$
}

# toggle status of the builder in the master scoreboard
# this MUST be the last operation in the batch!
# TODO: locking on FTP area required
set_status( )
{
	PLATFORM=$1
	ARCH=$2
	STATUS=$3
	
	touch /tmp/manual_results.$$
	cat $base/../../data/manual_results | tr -s ' ' '_' > manual_results.in
	while read -r _NAME _ARCH _STATUS _VM_NAME _HOST_NAME; do
		__NAME=$_NAME
		__ARCH=$_ARCH
		__STATUS=$_STATUS
		__VM_NAME=`echo $_VM_NAME | tr -s '_' ' ' | tr -d \"`
		__HOST_NAME=$_HOST_NAME
		if test "x$__NAME" = "x$PLATFORM" -a "x$__ARCH" = "x$ARCH"; then
			__STATUS=$STATUS
		fi
		printf "$__NAME\t$__ARCH\t$__STATUS\t\"$__VM_NAME\"\t$__HOST_NAME\n" >> /tmp/manual_results.$$
	done <manual_results.in

	mv -f $base/../../data/manual_results $base/../../data/manual_results.bak
	cp -f /tmp/manual_results.$$ $base/../../data/manual_results
	chmod 0666 $base/../../data/manual_results

	rm -f manual_results.in /tmp/manual_results.$$
}
