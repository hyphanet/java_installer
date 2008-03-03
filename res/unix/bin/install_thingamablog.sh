#!/bin/sh

INSTALL_PATH="${INSTALL_PATH:-$PWD}"

cd "$INSTALL_PATH"

if test -e thingamablog.install
then
	rm -f thingamablog.install
	if test ! -e offline
	then
		echo "Downloading thingamablog"
		java -jar bin/sha1test.jar thingamablog/thingamablog.zip ./ >/dev/null 2>&1 || exit 1
	fi
	echo "Unzipping thingamablog"
	java -jar bin/uncompress.jar thingamablog.zip . >/dev/null 2>&1
fi
