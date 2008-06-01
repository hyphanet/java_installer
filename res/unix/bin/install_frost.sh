#!/bin/sh

. "$HOME/_install_toSource.sh"|| exit 0
cd "$INSTALL_PATH"

if test -e frost.install
then
	rm -f frost.install
	if test ! -e offline
	then
		echo "Downloading frost"
		java $JOPTS -jar bin/sha1test.jar frost.zip ./ >/dev/null 2>&1 || exit 1
	fi
	echo "Unzipping frost"
	mkdir frost
	java $JOPTS -jar bin/uncompress.jar frost.zip frost "$CAFILE" >/dev/null 2>&1
fi
