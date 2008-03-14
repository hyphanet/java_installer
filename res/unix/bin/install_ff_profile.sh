#!/bin/bash

cd "$INSTALL_PATH"
. _install_toSource.sh
POSSIBLE_NAMES="firefox mozilla mozilla-firefox iceweasel"

if test -e ff.install
then
	rm -f ff.install
	echo Detecting the location of Firefox
	for name in $POSSIBLE_NAMES
	do
		TRY="`which $name`"
		if test -n "$TRY"
		then
			echo $TRY > firefox.location
			echo Firefox found, creating a profile for freenet
			$TRY -no-remote -CreateProfile "freenet $PWD/firefox_profile" >/dev/null
			exit
		fi
	done
	echo The installer was unable to locate Mozilla Firefox on your computer
fi
