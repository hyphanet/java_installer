#!/bin/bash

INSTALL_PATH="${INSTALL_PATH:-$PWD}"

cd "$INSTALL_PATH"

if test -e thaw
then
	rm -f thaw
	if test ! -e offline
	then
		echo "Downloading Thaw"
		mkdir Thaw
		java -jar bin/sha1test.jar Thaw/Thaw.jar Thaw 2>&1 >/dev/null || exit 1
	fi
fi
