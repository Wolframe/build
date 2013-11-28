# create a .netrc file containing the credentials, so that 'ftp'
# can run non-interactivly
write_creds( )
{
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
}

# get current data and status for this builder
get_status( )
{
	write_creds

	cat >/tmp/build.$$ <<EOF
get manual_results
quit
EOF
	ftp -p $FTP_SERVER </tmp/build.$$

	grep `hostname` manual_results | tr -s ' ' '_' >/tmp/build.$$
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
	ftp -p $FTP_SERVER </tmp/build.$$

	_HOST=`hostname`
	touch /tmp/manual_results.$$
	cat manual_results | tr -s ' ' '_' > manual_results.in
	while read -r _NAME _ARCH _STATUS _VM_NAME _HOST_NAME; do
		__NAME=$_NAME
		__ARCH=$_ARCH
		__STATUS=$_STATUS
		__VM_NAME=`echo $_VM_NAME | tr -s '_' ' ' | tr -d \"`
		__HOST_NAME=$_HOST_NAME
		if test $__HOST_NAME = $_HOST; then
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
	ftp -p $FTP_SERVER </tmp/build.$$

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
	ftp -p $FTP_SERVER </tmp/build2.$$

	remove_creds
}