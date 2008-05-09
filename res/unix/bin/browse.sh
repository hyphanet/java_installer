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
	"`cat firefox.location`" -no-remote -P freenet "$1" &
}

maybeCreateFFProfile()
{
	if test -x "$1"
	then
		echo "$1" > firefox.location
		echo Firefox found, creating a profile for freenet
		"$1" "file://$INSTALL_PATH/dont-close-me.html" &
		"$1" -no-remote -CreateProfile "freenet $PWD/firefox_profile" >/dev/null
		browseURL "$URL"
		exit
	fi
}

if test -e firefox.location
then
	"`cat firefox.location`" "file://$INSTALL_PATH/dont-close-me.html" &
	browseURL "$URL"
else
	echo Detecting the location of Firefox
	for name in $POSSIBLE_NAMES
	do
		maybeCreateFFProfile "`which $name 2>/dev/null`"
	done

	if test `uname -s` = "Darwin"
	then
		maybeCreateFFProfile "$HOME/Applications/Firefox.app/Contents/MacOS/firefox"
		maybeCreateFFProfile "/Applications/Firefox.app/Contents/MacOS/firefox"
	fi

	echo The installer was unable to locate Mozilla Firefox
	echo on your computer. Be informed that Freenet *will*
	echo be slow for you unless you manually configure your
	echo browser : see "http://freenetproject.org/faq.html#connections"
	echo for detailed instructions.
	java -Djava.net.preferIPv4Stack=true -cp bin/browser.jar BareBonesBrowserLaunch "$URL" &
fi
