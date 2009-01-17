#!/bin/sh

cd "$INSTALL_PATH"
POSSIBLE_NAMES="iceweasel firefox mozilla mozilla-firefox"

# Wait until the installer has finished
while test ! -f Uninstaller/install.log
do
	sleep 1
done

if test $# -lt 1
then
	URL="`cat freenet.url.dat`"
else
	URL="$1"
fi

java -Djava.net.preferIPv4Stack=true -cp bin/browser.jar BareBonesBrowserLaunch "$URL" &
