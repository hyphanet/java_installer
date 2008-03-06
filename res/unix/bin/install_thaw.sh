#!/bin/bash

cd "$INSTALL_PATH"
source _install_toSource.sh

if test -e thaw.install
then
	rm -f thaw.install
	if test ! -e offline
	then
		echo "Downloading Thaw"
		mkdir Thaw
		java $JOPTS -jar bin/sha1test.jar Thaw/Thaw.jar Thaw >/dev/null 2>&1 || exit 1
	fi
fi
