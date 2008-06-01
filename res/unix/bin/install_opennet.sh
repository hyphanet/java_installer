#!/bin/sh

. "$HOME/_install_toSource.sh"|| exit 0
cd "$INSTALL_PATH"

if test -e opennet.install
then
	rm -f opennet.install
	if test ! -e offline
	then
		echo "Downloading the Opennet seednode file"
		java $JOPTS -jar bin/sha1test.jar seednodes.fref . "$CAFILE" >/dev/null 2>&1 || exit 1
	fi
fi
