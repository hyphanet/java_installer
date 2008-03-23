#!/bin/sh

. _install_toSource.sh
cd "$INSTALL_PATH"

if test -e jsite.install
then
	rm -f jsite.install
	if test ! -e offline
	then
		echo "Downloading jSite"
		mkdir jSite
		java $JOPTS -jar bin/sha1test.jar jSite/jSite.jar jSite >/dev/null 2>&1 || exit 1
	fi
fi
