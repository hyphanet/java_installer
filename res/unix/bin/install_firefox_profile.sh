#!/bin/sh

. "$HOME/_install_toSource.sh" || exit 0
cd "$INSTALL_PATH"

if test -e firefox_profile.install
then
	echo "Downloading the custom firefox profile"
	if test ! -e offline
	then
		java $JOPTS -jar bin/sha1test.jar firefox_profile.zip . "$CAFILE" >/dev/null 2>&1 || exit 1
	fi
	mkdir -p firefox_profile
	java $JOPTS -jar bin/uncompress.jar firefox_profile.zip firefox_profile 2>&1 >/dev/null
	rm -f firefox_profile.install
fi
