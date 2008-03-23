#!/bin/sh

. "$HOME/_install_toSource.sh"
cd "$INSTALL_PATH"

if test ! -e offline
then
	echo "Downloading freenet-stable-latest.jar"
	java $JOPTS -jar bin/sha1test.jar freenet-stable-latest.jar "$INSTALL_PATH" >/dev/null 2>&1 || exit 1 
fi

rm -f freenet.jar
ln -sf freenet-stable-latest.jar freenet.jar
