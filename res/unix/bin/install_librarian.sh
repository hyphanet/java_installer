#!/bin/sh

INSTALL_PATH="${INSTALL_PATH:-$PWD}"

cd "$INSTALL_PATH"

if test -e xmllibrarian -a -e plug
then
	echo "Enabling the XMLLibrarian plugin"
	if test ! -e plugins; then mkdir plugins; fi
	PLUGINS="`cat plug`"
	echo "plugins.XMLLibrarian.XMLLibrarian@file://$INSTALL_PATH/plugins/XMLLibrarian.jar;$PLUGINS" > plug2
	mv -f plug2 plug
	if test ! -e offline
	then
		java -jar bin/sha1test.jar plugins/XMLLibrarian.jar.url plugins >/dev/null 2>&1
	fi
	mv -f plugins/XMLLibrarian.jar.url plugins/XMLLibrarian.jar
	rm -f plugins/XMLLibrarian.jar.url
	rm -f xmllibrarian
fi
