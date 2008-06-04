#!/bin/sh

. "$HOME/_install_toSource.sh" || exit 0
cd "$INSTALL_PATH"

if test ! -e offline
then
	echo "Downloading freenet-ext.jar"
	java $JOPTS -jar bin/sha1test.jar freenet-ext.jar "$INSTALL_PATH" "$CAFILE" >/dev/null 2>&1 || exit 1
fi
