#!/bin/bash

INSTALL_PATH="${INSTALL_PATH:-$PWD}"

cd "$INSTALL_PATH"

if test -e jsite
then
	rm -f jsite
	echo "Downloading jSite"
	java -jar bin/sha1test.jar jSite/jSite.jar ./ &>/dev/null || exit 1
fi
