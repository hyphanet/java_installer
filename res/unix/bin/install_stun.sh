#!/bin/sh

. "$HOME/_install_toSource.sh" || exit 0
cd "$INSTALL_PATH"
if test ! -d plugins; then mkdir plugins; fi 2>&1 >/dev/null

	echo "Downloading the STUN plugin"
	if test ! -f offline
	then
		echo java $JOPTS -jar bin/sha1test.jar JSTUN.jar plugins "$CAFILE"
		java $JOPTS -jar bin/sha1test.jar JSTUN.jar plugins "$CAFILE" >/dev/null 2>&1
	fi
