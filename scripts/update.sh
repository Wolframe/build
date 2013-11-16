#!/bin/sh

case "$0" in
	/*)
		base=`dirname $0`
		;;
	
	*)
		base=`pwd`/`dirname $0`
		;;
esac

LOCK_FILE=$base/../logs/update.lock
if test -f $LOCK_FILE; then
	exit 0
fi

touch $LOCK_FILE

$base/update_metadata.sh 2>&1 >$base/../logs/update.log
$base/generate_index.sh 2>&1 >>$base/../logs/update.log
$base/download_newest_logs.sh 2>&1 >>$base/../logs/update.log
$base/generate_index.sh 2>&1 >>$base/../logs/update.log
$base/update_binaries.sh 2>&1 >>$base/../logs/update.log

# for debugging
#cat $base/../logs/update.log 1>&2

rm -f $LOCK_FILE
