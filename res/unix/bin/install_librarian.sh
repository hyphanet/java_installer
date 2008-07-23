#!/bin/sh

. "$HOME/_install_toSource.sh" || exit 0
cd "$INSTALL_PATH"

if test -f xmllibrarian -a -f plug
then
	echo "Enabling the XMLLibrarian plugin"
	if test ! -e plugins; then mkdir plugins; fi
	PLUGINS="`cat plug`"
	echo "XMLLibrarian;$PLUGINS" > plug2
	mv -f plug2 plug
	if test ! -f offline
	then
		java $JOPTS -jar bin/sha1test.jar XMLLibrarian.jar plugins "$CAFILE" >/dev/null 2>&1
	fi
	rm -f xmllibrarian
fi
