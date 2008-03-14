#!/bin/sh

INSTALL_PATH="${INSTALL_PATH:-$PWD}"
cd "$INSTALL_PATH"

if test $# -lt 1
then
	URL="http://127.0.0.1:8888"
else
	URL="$1"
fi

if test -e firefox.location
then
	`cat firefox.location` -no-remote -p freenet "$URL" &
else
	java -Djava.net.preferIPv4Stack=true -cp bin/browser.jar BareBonesBrowserLaunch "$URL" &
fi
