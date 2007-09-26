#!/bin/sh

INSTALL_PATH="${INSTALL_PATH:-$PWD}"

cd "$INSTALL_PATH"

if test -e librarian -a -e plug
then
	echo "Enabling the Librarian plugin"
	if test ! -e plugins; then mkdir plugins; fi 2>&1 >/dev/null
	PLUGINS="`cat plug`"
	echo "plugins.Librarian.Librarian@file://$INSTALL_PATH/plugins/Librarian.jar;$PLUGINS" > plug2
	mv -f plug2 plug
	if test ! -e offline
	then
		java -jar bin/sha1test.jar plugins/Librarian.jar.url plugins 2>&1 >/dev/null
	fi
	mv -f plugins/Librarian.jar.url plugins/Librarian.jar
	rm -f plugins/Librarian.jar.url
	rm -f librarian
fi
