#!/bin/bash

INSTALL_PATH="${INSTALL_PATH:-$PWD}"

cd "$INSTALL_PATH"

if test ! -e offline
then
	echo "Downloading freenet-stable-latest.jar"
	java -jar bin/sha1test.jar freenet-stable-latest.jar "$INSTALL_PATH" 2>&1 >/dev/null || exit 1 
fi

rm -f freenet.jar
ln -sf freenet-stable-latest.jar freenet.jar 2>&1 >/dev/null
