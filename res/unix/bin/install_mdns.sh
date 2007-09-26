#!/bin/sh

INSTALL_PATH="${INSTALL_PATH:-$PWD}"

cd "$INSTALL_PATH"

if test -e mdns -a -e plug
then
	echo "Enabling the MDNSDiscovery plugin"
	if test ! -e plugins; then mkdir plugins; fi 2>&1 >/dev/null
	PLUGINS="`cat plug`"
	echo "plugins.MDNSDiscovery.MDNSDiscovery@file://$INSTALL_PATH/plugins/MDNSDiscovery.jar;$PLUGINS" > plug2
	mv -f plug2 plug
	if test ! -e offline
	then
		java -jar bin/sha1test.jar plugins/MDNSDiscovery.jar.url plugins >/dev/null 2>&1
	fi
	mv -f plugins/MDNSDiscovery.jar.url plugins/MDNSDiscovery.jar
	rm -f plugins/MDNSDiscovery.jar.url
	rm -f mdns
fi
