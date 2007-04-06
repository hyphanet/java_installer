#!/bin/bash

INSTALL_PATH="${INSTALL_PATH:-$PWD}"

cd "$INSTALL_PATH"

if test -e thaw
then
	rm -f thaw
	echo "Downloading Thaw"
	java -jar bin/sha1test.jar Thaw/Thaw.jar ./ &>/dev/null || exit 1
fi
