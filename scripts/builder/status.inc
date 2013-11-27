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
	while read -r NAME ARCH STATUS VM_NAME HOST_NAME; do
		OSB_NAME=$NAME
		OSB_ARCH=$ARCH
		OSB_STATUS=$STATUS
		OSB_VM_NAME=`echo $VM_NAME | tr -s '_' ' ' | tr -d \"`
		OSB_HOST_NAME=$HOST_NAME
	done </tmp/build.$$

	rm -f /tmp/build.$$ manual_results

	remove_creds
}

write_status( )
{
	RET=1
}
