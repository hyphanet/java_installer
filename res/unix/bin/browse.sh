#!/bin/sh

cd "$INSTALL_PATH"
POSSIBLE_NAMES="firefox mozilla mozilla-firefox iceweasel"

if test $# -lt 1
then
	URL="http://127.0.0.1:8888"
else
	URL="$1"
fi

browseURL()
{
	`cat firefox.location` -no-remote -P freenet "$1" &
}

if test -e firefox.location
then
	`cat firefox.location` -no-remote "about:blank" &
	browseURL "$URL"
else
	echo Detecting the location of Firefox
	for name in $POSSIBLE_NAMES
	do
		TRY="`which $name`"
		if test -n "$TRY"
		then
			echo $TRY > firefox.location
			echo Firefox found, creating a profile for freenet
			$TRY -no-remote "about:blank" &
			$TRY -no-remote -CreateProfile "freenet $PWD/firefox_profile" >/dev/null
			browseURL "$URL"
			exit
		fi
	done
	echo The installer was unable to locate Mozilla Firefox on your computer
	java -Djava.net.preferIPv4Stack=true -cp bin/browser.jar BareBonesBrowserLaunch "$URL" &
fi
