# global lock directory, atomar test-and-set in shell
global_lock( )
{
	__count=0
	while ! mkdir /root/.build-lock; do
		sleep 30
		__count=`expr $__count + 1`
		if test $__count -gt 10; then
			echo "FATAL: unable to lock '/root/.build-lock'! Check manually!" 1>&2
			exit 1
		fi
	done
}

global_unlock( )
{
	rmdir /root/.build-lock
}

# create a .netrc file containing the credentials, so that 'ftp'
# can run non-interactivly
write_creds( )
{
	__count=0
	while test -f $HOME/.netrc-lock; do
		sleep 30
		__count=`expr $__count + 1`
		if test $__count -gt 10; then
			echo "FATAL: unable to lock .netrc! Check manually!" 1>&2
			exit 1
		fi
	done
	touch $HOME/.netrc-lock

	cat >>$HOME/.netrc <<EOF
machine $FTP_SERVER login $FTP_USER password $FTP_PASS
EOF
	chmod 0600 $HOME/.netrc
}

# restore .netrc file to the former state
# TODO: parallel runs and locking!
remove_creds( )
{
	grep -v "machine $FTP_SERVER" < $HOME/.netrc > /tmp/build.$$
	mv -f /tmp/build.$$ $HOME/.netrc

	rm -f $HOME/.netrc-lock
}

get_hostname( )
{
	case $PLATFORM in
		NETBSD|SUNOS)
			HOST=`hostname`
			;;

		LINUX|FREEBSD)
			HOST=`hostname -f`
			;;
	esac
}

# get current git revision we are building locally and on OBS
get_git_version( )
{
	write_creds

	cat >/tmp/build.$$ <<EOF
get GIT_VERSION
quit
EOF
	ftp $FTP_SERVER </tmp/build.$$ >/dev/null

	OSB_GIT_VERSION=`cat GIT_VERSION`

	rm -f /tmp/build.$$ GIT_VERSION

	remove_creds
}

# get file with a list of operations we must perform
get_operations( )
{
	write_creds

	cat >/tmp/build.$$ <<EOF
get OPERATIONS
quit
EOF
	ftp $FTP_SERVER </tmp/build.$$ >/dev/null

	OPERATIONS=`cat OPERATIONS`
	OPERATION_CLEAN=0
	OPERATION_OSUPDATE=0
	OPERATION_BUILD=0
	OPERATION_PUBLISH=0
	for _op in $OPERATIONS; do
		case $_op in
			clean)
				OPERATION_CLEAN=1
				;;
			osupdate)
				OPERATION_OSUPDATE=1
				;;
			build)
				OPERATION_BUILD=1
				;;
			publish)
				OPERATION_PUBLISH=1
				;;
		esac
	done

	rm -f /tmp/build.$$ OPERATIONS

	remove_creds
}

# get current data and status for this builder
get_status( )
{
	write_creds

	cat >/tmp/build.$$ <<EOF
get manual_results
quit
EOF
	ftp $FTP_SERVER </tmp/build.$$ >/dev/null

	get_hostname
	grep $HOST manual_results | tr -s ' ' '_' >/tmp/build.$$
	while read -r _NAME _ARCH _STATUS _VM_NAME _HOST_NAME; do
		OSB_NAME=$_NAME
		OSB_ARCH=$_ARCH
		OSB_STATUS=$_STATUS
		OSB_VM_NAME=`echo $_VM_NAME | tr -s '_' ' ' | tr -d \"`
		OSB_HOST_NAME=$_HOST_NAME
	done </tmp/build.$$

	rm -f /tmp/build.$$ manual_results

	remove_creds
}

# toggle status of the builder in the master scoreboard
# this MUST be the last operation in the batch!
# TODO: locking on FTP area required
set_status( )
{
	write_creds

	cat >/tmp/build.$$ <<EOF
get manual_results
quit
EOF
	ftp $FTP_SERVER </tmp/build.$$ >/dev/null

	get_hostname
	touch /tmp/manual_results.$$
	cat manual_results | tr -s ' ' '_' > manual_results.in
	while read -r _NAME _ARCH _STATUS _VM_NAME _HOST_NAME; do
		__NAME=$_NAME
		__ARCH=$_ARCH
		__STATUS=$_STATUS
		__VM_NAME=`echo $_VM_NAME | tr -s '_' ' ' | tr -d \"`
		__HOST_NAME=$_HOST_NAME
		if test $__HOST_NAME = $HOST; then
			__STATUS=$1
		fi
		printf "$__NAME\t$__ARCH\t$__STATUS\t\"$__VM_NAME\"\t$__HOST_NAME\n" >> /tmp/manual_results.$$
	done <manual_results.in

	mv -f manual_results manual_results.bak
	mv -f /tmp/manual_results.$$ manual_results

	cat >/tmp/build.$$ <<EOF
put manual_results
quit
EOF
	ftp $FTP_SERVER </tmp/build.$$ >/dev/null

	rm -f manual_results.in manual_results manual_results.bak

	remove_creds
}

upload_file( )
{
	_PATH=$1
	
	write_creds

	_DIR=`dirname $_PATH`
	_FILE=`basename $_PATH`

	cat >/tmp/build2.$$ <<EOF
lcd $_DIR
cd $OSB_NAME
cd $OSB_ARCH
put $_FILE
quit
EOF
	ftp $FTP_SERVER </tmp/build2.$$ >/dev/null

	remove_creds
}
