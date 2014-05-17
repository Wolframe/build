#!/bin/sh

case "$0" in
	/*)
		base=`dirname $0`
		;;
	
	*)
		base=`pwd`/`dirname $0`
		;;
esac

LOCK_FILE=$base/../../logs/update.lock
if test -f $LOCK_FILE; then
	exit 0
fi

touch $LOCK_FILE

LOG_FILE=$base/../../logs/update.log

$base/update_metadata.sh 2>&1 >$LOG_FILE
$base/buildlocal.sh 2>&1 >>$LOG_FILE
$base/generate_index.sh 2>&1 >>$LOG_FILE
$base/download_newest_logs.sh 2>&1 >>$LOG_FILE
$base/extract_test_results.sh 2>&1 >>$LOG_FILE
$base/generate_index.sh 2>&1 >>$LOG_FILE
$base/update_binaries.sh 2>&1 >>$LOG_FILE
$base/cleanup.sh 2>&1 >>$LOG_FILE

# for debugging
#cat $LOG_FILE 1>&2

rm -f $LOCK_FILE
