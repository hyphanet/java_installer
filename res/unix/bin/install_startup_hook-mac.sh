#!/bin/sh

INSTALL_PATH="${INSTALL_PATH:-$PWD}"
STARTUP_PATH="/Library/StartupItems/"
SCRIPT="$STARTUP_PATH/Freenet/Freenet.sh"
SCRIPT_PLIST="$STARTUP_PATH/Freenet/Freenet.plist"

cd "$INSTALL_PATH"

echo "Creating a startup script for Freenet"

if test ! -d $STARTUP_PATH
then
	mkdir $STARTUP_PATH 2>&1 > >/dev/null
fi

mkdir $STARTUP_PATH/Freenet 2>&1 > >/dev/null
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
