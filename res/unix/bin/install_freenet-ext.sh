#!/bin/bash

cd "$INSTALL_PATH"
source _install_toSource.sh

if test ! -e offline
then
	echo "Downloading freenet-ext.jar"
	java $JOPTS -jar bin/sha1test.jar freenet-ext.jar "$INSTALL_PATH" >/dev/null 2>&1 || exit 1
fi
