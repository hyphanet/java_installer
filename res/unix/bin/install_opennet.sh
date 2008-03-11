#!/bin/bash

cd "$INSTALL_PATH"
. _install_toSource.sh

if test -e opennet.install
then
	rm -f opennet.install
	if test ! -e offline
	then
		echo "Downloading the Opennet seednode file"
		java $JOPTS -jar bin/sha1test.jar opennet/seednodes.fref . >/dev/null 2>&1 || exit 1
	fi
fi
