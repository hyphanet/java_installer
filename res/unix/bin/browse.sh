#!/bin/sh

cd "$INSTALL_PATH"
POSSIBLE_NAMES="iceweasel firefox mozilla mozilla-firefox"

if test $# -lt 1
then
	URL="http://127.0.0.1:8888"
else
	URL="$1"
fi

# Wait until the installer has finished
while test ! -f Uninstaller/install.log
do
	sleep 1
done

java -Djava.net.preferIPv4Stack=true -cp bin/browser.jar BareBonesBrowserLaunch "$URL" &
