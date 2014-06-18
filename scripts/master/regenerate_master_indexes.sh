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

echo "<builds>"
echo "<!-- INSERT -->"

REPO_CACHE=$CACHE_DIR/repo.cache
archs=`cat $REPO_CACHE | cut -f 2 | sort | uniq`
platforms=`cat $REPO_CACHE | cut -f 1 | sort | uniq`
REVISIONS=`find $DATA_DIR -maxdepth 1 -type d | xargs -n 1 basename | grep -E '^[0-9]{1,4}$' | sort -nr`
for revision in $REVISIONS; do
	
	echo "Reconstructing build results of revision $revision." 1>&2
	
	echo -n "<build><revision>$revision</revision>"

	MAIN_GIT_VERSION=''
	for arch in $archs; do
		for platform in $platforms; do
			DEST_DIR=$DATA_DIR/$revision/$arch/$platform
			LOG_FILE=$DEST_DIR/log.xml
			if test -f $LOG_FILE; then
				STATUS=`grep '<status>' $LOG_FILE | cut -f 2 -d '>' | cut -f 1 -d '<'`
				GIT_VERSION=`grep '<git_version>' $LOG_FILE | cut -f 2 -d '>' | cut -f 1 -d '<'`
				if test "x$MAIN_GIT_VERSION" = "x"; then
					MAIN_GIT_VERSION=$GIT_VERSION
					echo -n "<git_version>$GIT_VERSION</git_version><results>"
				else
					if test "$GIT_VERSION" != "$MAIN_GIT_VERSION"; then
						echo "WARN: Git version mismatch for same OSB revision ($GIT_VEERSION, main $MAIN_GIT_VERSION)" 1>2
					fi
				fi
				echo -n "<result><platform>$platform</platform><arch>$arch</arch><status>$STATUS</status></result>"
			fi
		done
	done

	echo "</results></build>"

done

echo "</builds>"
