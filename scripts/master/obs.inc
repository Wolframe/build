update_and_get_latest_obs_revision( )
{
	cd $OSC_HOME/$OSC_PROJECT
	osc -q up
	if test $? != 0; then
		echo "OBS local repository update failure. Check network or OSC workspace for errors!" 1>&2
		exit 1
	fi
	OSC_REVISION=`osc info | grep Revision | cut -f 2 -d ' '`
	if test "x$OSC_REVISION" = "x"; then
		echo "OSC revision cannot be determined. Check network or OSC workspace for errors!" 1>&2
		exit 1
	fi
}
