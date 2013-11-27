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

cd $OSC_HOME/$OSC_PROJECT
osc up
OSC_REVISION=`osc info | grep Revision | cut -f 2 -d ' '`

BINARY_OSC_VERSION_FILE=$CACHE_DIR/BINARY_OSC_VERSION

if test -f $BINARY_OSC_VERSION_FILE; then
	BINARY_OSC_VERSION=`cat $CACHE_DIR/BINARY_OSC_VERSION`
else
	BINARY_OSC_VERSION=0
fi

if test $OSC_REVISION -le $BINARY_OSC_VERSION; then
	echo "Binaries are up to date (OSC version is $BINARY_OSC_VERSION)"
	exit 0
fi


echo "Updating binaries for project '$OSC_PROJECT'.."

REPO_CACHE=$CACHE_DIR/repo.cache
archs=`cat $REPO_CACHE | cut -f 2 | sort | uniq`
platforms=`cat $REPO_CACHE | cut -f 1 | sort | uniq`

# check first if we are currently building, in this
# case wait and don't download binaries right now
OLDIFS=$IFS
osc results > /tmp/results.$$
cut -f1-3 $base/../../data/manual_results >> /tmp/results.$$
while read -r PLATFORM ARCH STATUS; do
	if test $STATUS != "succeeded" -a $STATUS != "failed" -a $STATUS != 'disabled' -a $STATUS != 'unresolvable'; then
		echo "Not updating binaries now, platform $PLATFORM, arch $ARCH is still building.."
		exit 0
	fi
done < /tmp/results.$$
rm /tmp/results.$$
IFS=$OLDIFS

# see if the download directory structure exists
if test ! -d $DOWNLOAD_DIR; then
	mkdir $DOWNLOAD_DIR
fi

rm -rf binaries

for arch in $archs; do
	for platform in $platforms; do
		dir=$DOWNLOAD_DIR/$platform/$arch
		if test ! -d $dir; then
			mkdir -p $dir
		else
			rm -rf $dir/$PROJECT_PREFIX*
		fi
		
		echo "Getting packages for $platform, $arch"
		osc -q getbinaries $platform $arch >/dev/null 2>&1
		mv -fuv binaries/*.rpm $dir 2>/dev/null
		mv -fuv binaries/*.deb $dir 2>/dev/null
		mv -fuv binaries/*.pkg.tar.xz $dir 2>/dev/null
		rm -rf binaries 2>/dev/null
		/sbin/restorecon -Rv $dir >/dev/null 2>&1
	done
done

echo "$OSC_REVISION" > $BINARY_OSC_VERSION_FILE

echo "Done."
