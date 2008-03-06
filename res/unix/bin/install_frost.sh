#!/bin/bash

cd "$INSTALL_PATH"
source _install_toSource.sh

if test -e frost.install
then
	rm -f frost.install
	if test ! -e offline
	then
		echo "Downloading frost"
		java $JOPTS -jar bin/sha1test.jar frost/frost.zip ./ >/dev/null 2>&1 || exit 1
	fi
	echo "Unzipping frost"
	mkdir frost
	java $JOPTS -jar bin/uncompress.jar frost.zip frost >/dev/null 2>&1
fi
