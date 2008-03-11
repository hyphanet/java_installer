#!/bin/sh

cd "$INSTALL_PATH"
. _install_toSource.sh

if test -e thingamablog.install
then
	rm -f thingamablog.install
	if test ! -e offline
	then
		echo "Downloading thingamablog"
		java $JOPTS -jar bin/sha1test.jar thingamablog/thingamablog.zip ./ >/dev/null 2>&1 || exit 1
	fi
	echo "Unzipping thingamablog"
	java $JOPTS -jar bin/uncompress.jar thingamablog.zip . >/dev/null 2>&1
fi
