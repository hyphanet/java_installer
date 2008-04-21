#!/bin/sh
# This script create a startup script for Freenet under Mac OS X
# 2 behaviour:
# -pre 10.4.x: use /Library/StartupItems/
# -post 10.4.x: use launchd
#
# You can send insult at nico%at%thenico%dot%fr%dot%eu%dot%org

function old_macosx () {

STARTUP_PATH=""
SCRIPT="$STARTUP_PATH/Freenet/Freenet.sh"
SCRIPT_PLIST="$STARTUP_PATH/Freenet/Freenet.plist"

. "$HOME/_install_toSource.sh"
cd "$INSTALL_PATH"

echo "Creating a startup script for Freenet"

if test ! -d $STARTUP_PATH
then
	mkdir $STARTUP_PATH 2>&1 >/dev/null
fi

mkdir $STARTUP_PATH/Freenet 2>&1 >/dev/null
rm -f $SCRIPT
echo "#!/bin/sh" >> $SCRIPT
echo ". /etc/rc.common" >> $SCRIPT
echo "# This script will start up Freenet" >> $SCRIPT
echo 'ConsoleMessage "Starting Freenet' >> $SCRIPT
echo "export HOME=\"$INSTALL_PATH\"" >> $SCRIPT
echo "cd \"$INSTALL_PATH\"" >> $SCRIPT
echo "./run.sh start" >> $SCRIPT

chmod 555 $SCRIPT

rm -f $SCRIPT_PLIST
echo '{' >>  $SCRIPT_PLIST
echo "Description = \"Freenet\";" >>  $SCRIPT_PLIST
echo "Provides = (\"Freenet\");" >>  $SCRIPT_PLIST
echo "Requires        = (\"NetInfo\");" >>  $SCRIPT_PLIST
echo "OrderPreference = \"last\";" >>  $SCRIPT_PLIST
echo '}' >>  $SCRIPT_PLIST
}

function new_macosx () {
STARTUP_FILE="/Library/LaunchDaemons/org.freenetproject.freenet.plist"

cd "$INSTALL_PATH"

echo "Creating a startup script for Freenet"

if test ! -d $STARTUP_PATH
then
	mkdir $STARTUP_PATH 2>&1 >/dev/null
fi

# No race condition, please :)
touch "$STARTUP_FILE"  2>&1 >/dev/null
chmod 755 $STARTUP_FILE  2>&1 >/dev/null

touch "$STARTUP_FILE".tmp  2>&1 >/dev/null
chmod 755 $STARTUP_FILE.tmp  2>&1 >/dev/null

cat  >> "$STARTUP_FILE" << 'BUG_SCRIPT'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN"
	"http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Disabled</key>
	<false/>
	<key>Label</key>
	<string>org.freenetproject.freenet</string>
	<key>Program</key>
		<string>REPLACE_WITH_PATH/bin/wrapper-macosx-universal-32</string>
	<key>ProgramArguments</key>
	<array>
		<string>REPLACE_WITH_PATH/bin/wrapper-macosx-universal-32</string>
		<string>-c</string>
		<string>REPLACE_WITH_PATH/wrapper.conf</string>
		<string>wrapper.syslog.ident=Freenet</string>
		<string>wrapper.pidfile=REPLACE_WITH_PATH/Freenet.pid</string>
		<string>wrapper.daemonize=TRUE</string>
		<string>wrapper.ignore_signals=REPLACE_WITH_PATH/Freenet.anchor</string>
		<string>wrapper.ignore_signals=TRUE</string>
		<string>wrapper.lockfile=REPLACE_WITH_PATH/Freenet</string>
	</array>
	<key>WorkingDirectory</key>
		<string>REPLACE_WITH_PATH</string>
	<key>UserName</key>
		<string>REPLACE_WITH_USER</string>
	<key>ServiceDescription</key>
		<string>Freenet is a censorhip-resistent darknet.</string>
	<key>RunAtLoad</key>
	<true/>
	<key>OnDemand</key>
	<false/>
	<key>StandardErrorPath</key>
		<string>/tmp/freenet-start</string>
</dict>
</plist>
BUG_SCRIPT

# GRUIK CODE !!
sed "s/REPLACE_WITH_PATH/$INSTALL_PATH/" "$STARTUP_FILE" | sed "s/REPLACE_WITH_USER/$USER/" "$STARTUP_FILE" >  "$STARTUP_FILE".tmp
mv "$STARTUP_FILE".tmp "$STARTUP_FILE"  2>&1 >/dev/null 
chmod 755 $STARTUP_FILE  2>&1 >/dev/null



launchctl load $STARTUP_FILE  2>&1 >/dev/null

}

if [ -x /etc/launchd.conf]
then
new_macosx
else
old_macosx
fi

exit 0
