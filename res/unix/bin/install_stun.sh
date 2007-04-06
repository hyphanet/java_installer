#!/bin/sh

INSTALL_PATH="${INSTALL_PATH:-$PWD}"

cd "$INSTALL_PATH"

if test -e stun
then
	echo "Enabling the STUN plugin"
	mkdir plugins &>/dev/null
	PLUGINS=`cat plug`
	echo "plugins.JSTUN.JSTUN@file://$INSTALL_PATH/plugins/JSTUN.jar;$PLUGINS" > plug2
	mv -f plug2 plug
	java -jar bin/sha1test.jar plugins/JSTUN.jar.url plugins &>/dev/null
	mv plugins/JSTUN.jar.url plugins/JSTUN.jar
	rm -f plugins/JSTUN.jar.url
	rm -f stun
fi
