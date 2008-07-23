#!/bin/sh

. "$HOME/_install_toSource.sh" || exit 0
cd "$INSTALL_PATH"

if test -f opennet.install
then
	rm -f opennet.install
	if test ! -f offline
	then
		echo "Downloading the Opennet seednode file"
		java $JOPTS -jar bin/sha1test.jar seednodes.fref . "$CAFILE" >/dev/null 2>&1 || exit 1
	fi
fi
