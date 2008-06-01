#!/bin/sh

. "$HOME/_install_toSource.sh"|| exit 0
cd "$INSTALL_PATH"

if test -e thaw.install
then
	rm -f thaw.install
	if test ! -e offline
	then
		echo "Downloading Thaw"
		mkdir Thaw
		java $JOPTS -jar bin/sha1test.jar Thaw.jar Thaw "$CAFILE" >/dev/null 2>&1 || exit 1
	fi
fi
