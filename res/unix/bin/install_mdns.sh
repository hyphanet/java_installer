#!/bin/sh

. "$HOME/_install_toSource.sh"|| exit 0
cd "$INSTALL_PATH"

if test -e mdns -a -e plug
then
	echo "Enabling the MDNSDiscovery plugin"
	if test ! -e plugins; then mkdir plugins; fi 2>&1 >/dev/null
	PLUGINS="`cat plug`"
	echo "MDNSDiscovery;$PLUGINS" > plug2
	mv -f plug2 plug
	if test ! -e offline
	then
		java $JOPTS -jar bin/sha1test.jar plugins/MDNSDiscovery.jar.url plugins "$CAFILE" >/dev/null 2>&1
		mv plugins/MDNSDiscovery.jar.url plugins/MDNSDiscovery.jar
	fi
	rm -f mdns
fi
