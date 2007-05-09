#!/bin/bash

INSTALL_PATH="${INSTALL_PATH:-$PWD}"

cd "$INSTALL_PATH"

if test -e frost
then
	rm -f frost
	if test ! -e offline
	then
		echo "Downloading frost"
		java -jar bin/sha1test.jar frost/frost.zip ./ &>/dev/null || exit 1
	fi
	echo "Unzipping frost"
	mkdir frost
	java -jar bin/uncompress.jar frost.zip frost &>/dev/null
fi
