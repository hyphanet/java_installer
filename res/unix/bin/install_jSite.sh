#!/bin/bash

INSTALL_PATH="${INSTALL_PATH:-$PWD}"

cd "$INSTALL_PATH"

if test -e jsite
then
	rm -f jsite
	if test ! -e offline
	then
		echo "Downloading jSite"
		mkdir jSite
		java -jar bin/sha1test.jar jSite/jSite.jar jSite 2>&1 >/dev/null || exit 1
	fi
fi
