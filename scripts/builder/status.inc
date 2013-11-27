write_creds( )
{
	cat >>$HOME/.netrc <<EOF
machine $FTP_SERVER login $FTP_USER password $FTP_PASS
EOF
	chmod 0600 $HOME/.netrc
}

remove_creds( )
{
	grep -v "machine $FTP_SERVER" < $HOME/.netrc > /tmp/build.$$
	mv -f /tmp/build.$$ $HOME/.netrc
}
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
		OSB_NAME=$_NAME
		OSB_ARCH=$_ARCH
		OSB_STATUS=$_STATUS
		OSB_VM_NAME=`echo $_VM_NAME | tr -s '_' ' ' | tr -d \"`
		OSB_HOST_NAME=$_HOST_NAME
		if test $OSB_HOST_NAME = $_HOST; then
			OSB_STATUS=$1
		fi
		printf "$OSB_NAME\t$OSB_ARCH\t$OSB_STATUS\t\"$OSB_VM_NAME\"\t$OSB_HOST_NAME\n" >> /tmp/manual_results.$$
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
