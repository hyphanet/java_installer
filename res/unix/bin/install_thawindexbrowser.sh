#!/bin/sh

. "$HOME/_install_toSource.sh" || exit 0
cd "$INSTALL_PATH"

if test -f thawindexbrowser -a -f plug
then
	echo "Enabling the ThawIndexBrowser plugin"
	if test ! -d plugins; then mkdir plugins; fi 2>&1 >/dev/null
	PLUGINS="`cat plug`"
	echo "ThawIndexBrowser;$PLUGINS" > plug2
	mv -f plug2 plug
	if test ! -f offline
	then
		java $JOPTS -jar bin/sha1test.jar ThawIndexBrowser.jar plugins "$CAFILE" >/dev/null 2>&1
	fi
	rm -f thawindexbrowser
fi
