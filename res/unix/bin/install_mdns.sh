#!/bin/sh

cd "$INSTALL_PATH"
source _install_toSource.sh

if test -e mdns -a -e plug
then
	echo "Enabling the MDNSDiscovery plugin"
	if test ! -e plugins; then mkdir plugins; fi 2>&1 >/dev/null
	PLUGINS="`cat plug`"
	echo "MDNSDiscovery;$PLUGINS" > plug2
	mv -f plug2 plug
	if test ! -e offline
	then
		java $JOPTS -jar bin/sha1test.jar plugins/MDNSDiscovery.jar.url plugins >/dev/null 2>&1
	fi
	rm -f mdns
fi
