guess_os( )
{
	UNAME_SYSTEM=`(uname -s) 2>/dev/null`
	UNAME_RELEASE=`(uname -r) 2>/dev/null`
	UNAME_VERSION=`(uname -v) 2>/dev/null`
	UNAME_MACHINE=`(uname -m) 2>/dev/null`

	LINUX_DIST=""
	LINUX_REV=""
	OSB_PLATFORM=""

	case "$UNAME_SYSTEM.$UNAME_RELEASE" in
		Linux*)		PLATFORM=LINUX
				OS_MAJOR_VERSION=`echo $UNAME_RELEASE | cut -d . -f 1`
				OS_MINOR_VERSION=`echo $UNAME_RELEASE | cut -d . -f 2`
				
				# LSB-system? Check for lsb-release
				if test -x /usr/bin/lsb_release; then
					dist=`/usr/bin/lsb_release -i | cut -f 2`
					rev=`/usr/bin/lsb_release -r | cut -f 2`
					case "$dist" in
						Ubuntu)
							LINUX_DIST='ubuntu'
							LINUX_REV=$rev
							;;
						
						Debian)
							LINUX_DIST='debian'
							LINUX_REV=`echo $rev | cut -f 1 -d.`
							;;
							
						*SUSE*)
							LINUX_DIST='suse'
							LINUX_REV=`echo $rev | tr -s ' ' '\t' | cut -f 2 -d ' '`
							;;

						CentOS)
							LINUX_DIST='redhat'
							LINUX_REV=`echo $rev | tr -s ' ' '\t' | cut -f 1 -d .`
							;;
							
						*Scientific*)
							LINUX_DIST='redhat'
							LINUX_REV=`echo $rev | tr -s ' ' '\t' | cut -f 1 -d .`
							osb_rev=`echo $rev | tr -s ' ' '\t' | cut -f 2`
							osb_major=`echo $osb_rev | cut -f 1 -d .`
							osb_minor=`echo $osb_rev | cut -f 2 -d .`
							if test $osb_minor -lt 10; then
								osb_minor="${osb_minor}0"
							fi
							OSB_PLATFORM="scilin_version ${osb_major}${osb_minor}"
							;;
						*)
							LINUX_DIST='unknown'
							LINUX_REV='unknown'
							OSB_PLATFORM='unknown'
							;;
					esac
				else
					# try the older way with release files in /etc
					
					if test -f /etc/arch-release; then
						LINUX_DIST='arch'
						LINUX_REV='current'
						if test "$OS_MAJOR_VERSION" = "3"; then
							OS_MINOR_VERSION=`echo $UNAME_RELEASE | cut -d . -f 2 | cut -d - -f 1`
						fi
					elif test -f /etc/debian_version; then
						LINUX_DIST='debian'
						LINUX_REV=`cat /etc/debian_version | cut -d . -f 1`
					elif test -f /etc/slackware-version; then
						LINUX_DIST='slackware'
						LINUX_REV=`cat /etc/slackware-version | cut -d ' ' -f 2 | cut -d . -f 1,2`
					elif test -f /etc/centos-release; then
						LINUX_DIST='redhat'
						LINUX_REV=`cat /etc/centos-release | cut -f 3 -d ' '`
						osb_major=`echo $LINUX_REV | cut -f 1 -d .`
						osb_minor=`echo $LINUX_REV | cut -f 2 -d .`
						if test $osb_minor -lt 10; then
							osb_minor="${osb_minor}0"
						fi
						OSB_PLATFORM="centos_version ${osb_major}${osb_minor}"
					elif test -f /etc/system-release; then
						LINUX_DIST='redhat'
						LINUX_REV=`cat /etc/system-release | cut -f 4 -d ' '`
						osb_major=`echo $LINUX_REV | cut -f 1 -d .`
						osb_minor=`echo $LINUX_REV | cut -f 2 -d .`
						if test $osb_minor -lt 10; then
							osb_minor="${osb_minor}0"
						fi
						OSB_PLATFORM="scilin_version ${osb_major}${osb_minor}"
					elif test -f /etc/fedora-release; then
						LINUX_DIST='redhat'
						LINUX_REV=`cat /etc/fedora-release | cut -f 3 -d ' '`
					elif test -f /etc/redhat-release; then
						LINUX_DIST='redhat'
						LINUX_REV=`cat /etc/redhat-release | sed s/.*release\ // | sed s/\ .*// | cut -f 1 -d .`
					elif test -f /etc/SuSE-release; then
						grep "SUSE Linux Enterprise Server" /etc/SuSE-release
						if test $? = 0; then
							LINUX_DIST='sles'
							LINUX_REV=`grep VERSION /etc/SuSE-release | cut -f 3 -d ' '`
						else
							LINUX_DIST='suse'
							LINUX_REV=`grep VERSION /etc/SuSE-release | cut -f 3 -d ' '`
						fi
					else
						LINUX_DIST='unknown'
						LINUX_REV='unknown'
						OSB_PLATFORM='unknown'
					fi
				fi
				;;

		FreeBSD*)	PLATFORM=FREEBSD
				OS_MAJOR_VERSION=`echo $UNAME_RELEASE | cut -d . -f 1`
				OS_MINOR_VERSION=`echo $UNAME_RELEASE | cut -d . -f 2 | cut -d - -f 1`
				;;
				
		NetBSD*)	PLATFORM=NETBSD
				OS_MAJOR_VERSION=`echo $UNAME_RELEASE | cut -d . -f 1`
				OS_MINOR_VERSION=`echo $UNAME_RELEASE | cut -d . -f 2`
				;;
				
		SunOS*)		PLATFORM=SUNOS
				OS_MAJOR_VERSION=`echo $UNAME_RELEASE | cut -d . -f 1`
				OS_MINOR_VERSION=`echo $UNAME_RELEASE | cut -d . -f 2`
				;;

		Darwin*)	PLATFORM=MACOS
				OS_MAJOR_VERSION=`echo $UNAME_RELEASE | cut -d . -f1`
				OS_MINOR_VERSION=`echo $UNAME_RELEASE | cut -d . -f2`
				;;

		*)
				PLATFORM=UNKNOWN
				echo "Unknown platform '$UNAME_SYSTEM $UNAME_RELEASE'"
				exit 1
	esac

	# the architecture

	case "$UNAME_MACHINE" in
		i*86*)		ARCH=x86
				;;
		x86_64|amd64)	ARCH=x86_64
				;;
		sun4u)		ARCH=sun4u
				;;
		armv6l)		ARCH=armv6l
				;;

		*)		ARCH=UNKNOWN
				echo "Unknown architecture '$UNAME_MACHINE'"
				exit 1
				
	esac

	ARCH=$ARCH
	PLATFORM=$PLATFORM
	OS_MAJOR_VERSION=$OS_MAJOR_VERSION
	OS_MINOR_VERSION=$OS_MINOR_VERSION
}
