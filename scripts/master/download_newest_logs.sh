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
archs=`cat $REPO_CACHE | cut -f 2 | sort | uniq`
platforms=`cat $REPO_CACHE | cut -f 1 | sort | uniq`

hinit states
if test $WANTED_REVISION = $OSC_REVISION; then
	OLDIFS=$IFS
	osc results > /tmp/results.$$
	cut -f1-3 $base/../../data/manual_results >> /tmp/results.$$
	while read -r PLATFORM ARCH STATUS; do
		hput states "${ARCH}_${PLATFORM}" $STATUS
	done < /tmp/results.$$
	rm /tmp/results.$$
	IFS=$OLDIFS
	
	GIT_VERSION=`cat GIT_VERSION`
else
	for arch in $archs; do
		for platform in $platforms; do
			STATUS=`xsltproc --stringparam revision $WANTED_REVISION \
				--stringparam arch $arch \
				--stringparam platform $platform \
				$base/../../xslt/get_status.xslt $base/../../xslt/empty.xml |\
				tr -d ' ' | tr -d "\n"`
			hput states "${arch}_${platform}" $STATUS
		done
	done
	
	GIT_VERSION='unknown'
fi

# see if web data directory is available, this will be the model
# for all our web pages
if test ! -d $DATA_DIR; then
	mkdir $DATA_DIR
fi


# logfile per architecture, platform and revision (only possible
# for newest build)
if test $WANTED_REVISION = $OSC_REVISION; then
	for arch in $archs; do
		for platform in $platforms; do
			DEST_DIR=$DATA_DIR/$WANTED_REVISION/$arch/$platform
			LOG_FILE=$DEST_DIR/log.txt
			if test ! -d $DEST_DIR; then
				mkdir -p $DEST_DIR
			fi
			STATUS=`hget states ${arch}_${platform}`
			case $STATUS in
				failed|succeeded)
					if test ! -f $LOG_FILE; then
						echo "Getting build log for $WANTED_REVISION, $arch, $platform.."
						osc buildlog $platform $arch > $LOG_FILE
					fi
					;;
				
				unresolvable)
					echo "" > $LOG_FILE
					;;
				
				*)
					echo "Ignoring build log for  $WANTED_REVISION, $arch, $platform because of status '$STATUS'.."
			esac
		done
	done
fi

# generate XM metadata per build
for arch in $archs; do
	for platform in $platforms; do
		DEST_DIR=$DATA_DIR/$WANTED_REVISION/$arch/$platform
		LOG_FILE=$DEST_DIR/log.txt
		XML_FILE=$DEST_DIR/log.xml
		STATUS=`hget states ${arch}_${platform}`
		
		case $STATUS in
			failed|succeeded)
				tail -n 25 < $LOG_FILE > /tmp/tail.$$
				TAIL=`cat /tmp/tail.$$ | sed -e 's~&~\&amp;~g' -e 's~<~\&lt;~g'  -e  's~>~\&gt;~g'`
				;;
			*)
				TAIL=''
				;;
		esac
				
		case $STATUS in
			failed|succeeded|unresolvable)
				echo "Generating meta XML for $WANTED_REVISION, $arch, $platform.."
				cat >$XML_FILE <<EOF
		<log>
			<revision>$WANTED_REVISION</revision>
			<arch>$arch</arch>
			<platform>$platform</platform>
			<status>$STATUS</status>
			<git_version>$GIT_VERSION</git_version>
			<tail>$TAIL</tail>
		</log>
EOF
				;;
				
			*)
				echo "ERROR: Unknown status '$STATUS'! Please fix!" 1>2
				;;
			
		esac
		
		if test -f /tmp/tail.$$; then
			rm /tmp/tail.$$
		fi
	done
done

hdestroy states
     
echo "Done."