#!/bin/sh

. "$HOME/_install_toSource.sh" || exit 0
cd "$INSTALL_PATH"

if test -f upnp -a -e plug
then
	echo "Enabling the UP&P plugin"
	if test ! -e plugins; then mkdir plugins; fi
	PLUGINS="`cat plug`"
	echo "UPnP;$PLUGINS" > plug2
	mv -f plug2 plug
	if test ! -e offline
	then
		java $JOPTS -jar bin/sha1test.jar UPnP.jar plugins "$CAFILE" >/dev/null 2>&1
	fi
	rm -f upnp
fi
