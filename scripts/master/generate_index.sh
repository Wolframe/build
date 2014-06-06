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
. $base/obs.inc

update_and_get_latest_obs_revision

echo "Updating status page for '$OSC_PROJECT', revision $OSC_REVISION.."

# see if web data directory is available, this will be the model
# for all our web pages
if test ! -d $DATA_DIR; then
	mkdir $DATA_DIR
fi

# main overview page with all runs
META_FILE=$DATA_DIR/index.xml

if test ! -f $META_FILE; then
	cat > $META_FILE <<EOF
<builds>
<!-- INSERT -->
</builds>
EOF
fi

# load status of current build
hinit states
OLDIFS=$IFS
RESULTS="<build>"
GIT_VERSION=`cat GIT_VERSION`
RESULTS="$RESULTS<revision>$OSC_REVISION</revision>"
RESULTS="$RESULTS<git_version>$GIT_VERSION</git_version>"
RESULTS="$RESULTS<results>"
osc results > /tmp/results.$$
cut -f1-3 $base/../../data/manual_results >> /tmp/results.$$
while read -r PLATFORM ARCH STATUS; do
	# build status
	hput states "${ARCH}_${PLATFORM}" $STATUS

	# if there is a test status, this one overrides ok states
	DEST_DIR=$DATA_DIR/$OSC_REVISION/$ARCH/$PLATFORM
	TEST_RESULT_FILE=$DEST_DIR/test_results.xml
	if test -f $TEST_RESULT_FILE; then
		TEST_STATUS=`sed -n 's/<status_total>\(.*\)<\/status_total>/\1/p' $TEST_RESULT_FILE`
		if test "x$STATUS" = "xsucceeded" -a "x$TEST_STATUS" = "xerror"; then
			STATUS="test_error"
		fi
	fi
	RESULTS="$RESULTS<result><platform>$PLATFORM</platform><arch>$ARCH</arch><status>$STATUS</status></result>"
done < /tmp/results.$$
rm /tmp/results.$$
RESULTS="$RESULTS</results>"
RESULTS="$RESULTS</build>"
IFS=$OLDIFS

# insert new 
grep "<revision>$OSC_REVISION</revision>" $META_FILE 2>/dev/null >/dev/null
if test $? -ne 0; then
	sed -i "s|<!-- INSERT -->|<!-- INSERT -->\n$RESULTS|g" $META_FILE
else
	sed -i "s|.*<revision>$OSC_REVISION</revision>.*|$RESULTS|g" $META_FILE
fi

# update build status in buildlog summary files
REPO_CACHE=$CACHE_DIR/repo.cache
archs=`cat $REPO_CACHE | cut -f 2 | sort | uniq`
platforms=`cat $REPO_CACHE | cut -f 1 | sort | uniq`
for arch in $archs; do
	for platform in $platforms; do
		DEST_DIR=$DATA_DIR/$OSC_REVISION/$arch/$platform
		XML_FILE=$DEST_DIR/log.xml
		TEST_RESULT_FILE=$DEST_DIR/test_results.xml
		# building successfull?
		if test -f $XML_FILE; then
			echo "Updating build status in buildlog meta XML for $OSC_REVISION, $arch, $platform.."
			STATUS=`hget states ${arch}_${platform}`
			sed -i "s|<status>[^<]*</status>|<status>$STATUS</status>|g" $XML_FILE
		fi
		# testing successfull?
		if test -f $TEST_RESULT_FILE; then
			echo "Updating test status in buildlog meta XML for $OSC_REVISION, $arch, $platform.."
			TEST_STATUS=`sed -n 's/<status_total>\(.*\)<\/status_total>/\1/p' $TEST_RESULT_FILE`
			if test "x$TEST_STATUS" = "xerror"; then
				sed -i "s|<status>[^<]*</status>|<status>test_error</status>|g" $XML_FILE
			fi
		fi
	done
done

hdestroy states

echo "Done."
