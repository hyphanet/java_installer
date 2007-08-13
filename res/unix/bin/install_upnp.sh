#!/bin/sh

INSTALL_PATH="${INSTALL_PATH:-$PWD}"

cd "$INSTALL_PATH"

if test -e upnp -a -e plug
then
	echo "Enabling the UP&P plugin"
	mkdir -p plugins &>/dev/null
	PLUGINS="`cat plug`"
	echo "plugins.UPnP.UPnP@file://$INSTALL_PATH/plugins/UPnP.jar;$PLUGINS" > plug2
	mv -f plug2 plug
	if test ! -e offline
	then
		java -jar bin/sha1test.jar plugins/UPnP.jar.url plugins &>/dev/null
	fi
	mv -f plugins/UPnP.jar.url plugins/UPnP.jar
	rm -f plugins/UPnP.jar.url
	rm -f upnp
fi
