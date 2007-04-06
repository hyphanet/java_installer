#!/bin/sh

INSTALL_PATH="${INSTALL_PATH:-$PWD}"

cd "$INSTALL_PATH"

if test -e librarian
then
	echo "Enabling the Librarian plugin"
	mkdir plugins &>/dev/null
	PLUGINS=`cat plug`
	echo "plugins.Librarian.Librarian@file://$INSTALL_PATH/plugins/Librarian.jar;$PLUGINS" > plug2
	mv -f plug2 plug
	java -jar bin/sha1test.jar plugins/Librarian.jar.url plugins &>/dev/null
	mv plugins/Librarian.jar.url plugins/Librarian.jar
	rm -f plugins/Librarian.jar.url
	rm -f librarian
fi
