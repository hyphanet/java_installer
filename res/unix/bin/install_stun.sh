#!/bin/sh

cd "$INSTALL_PATH"
source _install_toSource.sh

if test -e stun -a -e plug
then
	echo "Enabling the STUN plugin"
	if test ! -e plugins; then mkdir plugins; fi
	PLUGINS="`cat plug`"
	echo "JSTUN;$PLUGINS" > plug2
	mv -f plug2 plug
	if test ! -e offline
	then
		java $JOPTS -jar bin/sha1test.jar plugins/JSTUN.jar.url plugins >/dev/null 2>&1
	fi
	rm -f stun
fi
