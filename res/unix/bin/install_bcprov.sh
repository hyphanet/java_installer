#!/bin/sh

. "$HOME/_install_toSource.sh" || exit 0
cd "$INSTALL_PATH"

if test ! -f offline
then
	echo "Downloading bcprov-jdk15on-154.jar"
	java $JOPTS -jar bin/sha1test.jar bcprov-jdk15on-154.jar "$INSTALL_PATH" "$CAFILE" >/dev/null 2>&1 || exit 1
fi
