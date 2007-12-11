#!/bin/bash

INSTALL_PATH="${INSTALL_PATH:-$PWD}"

cd "$INSTALL_PATH"

if test -e opennet.install
then
	rm -f opennet.install
	echo "Downloading the Opennet seednode file"
	java -jar bin/sha1test.jar opennet/seednodes.fref . >/dev/null 2>&1 || exit 1
fi
