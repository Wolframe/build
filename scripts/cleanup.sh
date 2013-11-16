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

echo "Cleaning smoke tests for '$OSC_PROJECT'.."

# see if web data directory is available, go away if not..
if test ! -d $DATA_DIR; then
	exit 0
fi

# main overview page with all runs, we keep the top 10 build entries
META_FILE=$DATA_DIR/index.xml

# no metadata file, bail out..
if test ! -f $META_FILE; then
	exit 0
fi

# no archive meta file, create one
ARCHIVE_META_FILE=$META_FILE.archive

if test ! -f $ARCHIVE_META_FILE; then
	cat > $ARCHIVE_META_FILE <<EOF
<builds>
</builds>
EOF
fi

# create a new archive metafile
NEW_ARCHIVE_META_FILE=$META_FILE.archive.new
rm -f $NEW_ARCHIVE_META_FILE
echo "<builds>" > $NEW_ARCHIVE_META_FILE

# create a new metafile
NEW_META_FILE=$META_FILE.new
rm -f $NEW_META_FILE

# read old meta file and store newest N builds into new meta file
# store older entries into the beginning of the new archvie meta file
count=0
while read -r line; do
	case $line in
		*\<build\>*)
			count=`expr $count + 1`
			if test $count -le $MAX_BUILD_RESULTS_TO_SHOW; then
				echo $line >> $NEW_META_FILE
			else
				# remember meta file
				echo $line >> $NEW_ARCHIVE_META_FILE
				
				# do some scrubbing
				REVISION=`echo $line | sed -e "s/.*<revision>\(.*\)<\/revision>.*/\1/"`
				echo "Cleaning archive revision $REVISION.."
				find $REVISION -name log.txt -exec rm -f {} \;
			fi
			;;
		*)
			echo $line >> $NEW_META_FILE
			;;
	esac
done < $META_FILE

# read old archive meta file and copy all entries to new archive meta file
while read -r line; do
	case $line in
		*\<build\>*)
			echo $line >> $NEW_ARCHIVE_META_FILE
			;;
		*)
			;;
	esac
done < $ARCHIVE_META_FILE

# terminate new archive meta file
echo "</builds>" >> $NEW_ARCHIVE_META_FILE        

# now we rename the new files to the right ones and backup the old ones
mv -f $ARCHIVE_META_FILE $ARCHIVE_META_FILE.bak
mv -f $META_FILE $META_FILE.bak
mv -f $NEW_ARCHIVE_META_FILE $ARCHIVE_META_FILE
mv -f $NEW_META_FILE $META_FILE

echo "Done."
