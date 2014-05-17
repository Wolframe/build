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
. $base/hashmap.inc

cd $OSC_HOME/$OSC_PROJECT
osc -q up
OSC_REVISION=`osc info | grep Revision | cut -f 2 -d ' '`

if test $# -eq 1; then
	WANTED_REVISION=$1
else
	WANTED_REVISION=$OSC_REVISION
fi

REPO_CACHE=$CACHE_DIR/repo.cache
if test "x$1" != "x"; then
	archs=$1
else
	archs=`cat $REPO_CACHE | cut -f 2 | sort | uniq`
fi
if test "x$2" != "x"; then
	platforms=$2
else
	platforms=`cat $REPO_CACHE | cut -f 1 | sort | uniq`
fi
for arch in $archs; do
	for platform in $platforms; do
		DEST_DIR=$DATA_DIR/$WANTED_REVISION/$arch/$platform
		LOG_FILE=$DEST_DIR/log.txt
		XML_FILE=$DEST_DIR/log.xml
		TEST_RESULT_FILE=$DEST_DIR/test_results.xml
		
		# test results already exist?
		if test -f $TEST_RESULT_FILE; then
			continue
		fi
		
		# log file already there? can we extract test results already?
		if test ! -f $LOG_FILE -a ! -f $XML_FILE; then
			continue
		fi
		
		echo "Extracting test results for $arch $platform.."
		
		echo "<tests>" > $TEST_RESULT_FILE

		echo "<revision>$WANTED_REVISION</revision>" >> $TEST_RESULT_FILE
		echo "<arch>$arch</arch>"  >> $TEST_RESULT_FILE
		echo "<platform>$platform</platform>" >> $TEST_RESULT_FILE
		
		# first general test overviews
		awk '/Summary$/ {flag=1;next} /Test results$/ {flag=0} flag {print} ' \
			$LOG_FILE > _summary		
		nof_tests=`sed -n 's/\(\[ *[0-9]\+s\] \)\?\([0-9]\+\) tests in total$/\2/p' _summary`
		echo "<tests_total>$nof_tests</tests_total>" >> $TEST_RESULT_FILE
		failed_tests=`sed -n 's/\(\[ *[0-9]\+s\] \)\?\([0-9]\+\) tests failed$/\2/p' _summary`
		echo "<tests_failed>$failed_tests</tests_failed>" >> $TEST_RESULT_FILE
		rm -f _summary
		
		# statistics from gtestReport.txt per test binary run
		awk '/Test results$/ {flag=1;next} /Test result details$/ {flag=0} flag {print} ' \
			$LOG_FILE > _stats		
		cat _stats | while read line; do
			echo "$line" | sed -n 's/\(\[ *[0-9]\+s\] \)\?\(.*\) \(.*\) \(.*\) \(.*\)$/\2 \3 \4 \5/p' > _line
			grep -- '---' _line >/dev/null
			if test $? -eq 0; then
				continue
			fi
			nof_chars=`wc -c _line | tr -s ' ' '\t' | cut -f 1`
			if test $nof_chars -lt 10; then
				continue
			fi
			cat _line | xargs printf "<testsummary>\n  <name>%s</name>\n  <status>%s</status>\n  <tests_run>%s</tests_run>\n  <tests_failed>%s</tests_failed>\n</testsummary>\n" \
				>> $TEST_RESULT_FILE
			rm -f _line
		done
		rm -f _stats
		
		# XML from gtest
		awk '/Test result details$/ {flag=1;next} /<\/testresults>$/ {flag=0} flag {print} ' \
			$LOG_FILE > _xml
		cat _xml | while read line; do
			echo "$line" | sed -n 's/\(\[ *[0-9]\+s\] \)\?\(.*\)$/\2/p' > _line
			grep -- '---' _line >/dev/null
			if test $? -eq 0; then
				continue
			fi
			grep -- '^\[' _line >/dev/null
			if test $? -eq 0; then
				continue
			fi
			sed -i 's/\[ *[\.0-9]\+\] serial8250: too much work for irq4//g' _line
			cat _line >> $TEST_RESULT_FILE
			rm -f _line
		done
		rm -f _xml
		echo "</testresults>" >> $TEST_RESULT_FILE
		
		
		echo "</tests>" >> $TEST_RESULT_FILE
	done
done
