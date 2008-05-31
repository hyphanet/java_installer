#!/bin/sh

. "$HOME/_install_toSource.sh"|| exit 0
cd "$INSTALL_PATH"

if test -e stun -a -e plug
then
	echo "Enabling the STUN plugin"
	if test ! -e plugins; then mkdir plugins; fi
	PLUGINS="`cat plug`"
	echo "JSTUN;$PLUGINS" > plug2
	mv -f plug2 plug
	if test ! -e offline
	then
		java $JOPTS -jar bin/sha1test.jar plugins/JSTUN.jar.url plugins "$CAFILE" >/dev/null 2>&1
		mv plugins/JSTUN.jar.url plugins/JSTUN.jar
	fi
	rm -f stun
fi
