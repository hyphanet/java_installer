#!/bin/sh

. "$HOME/_install_toSource.sh"
cd "$INSTALL_PATH"

if test -e xmllibrarian -a -e plug
then
	echo "Enabling the XMLLibrarian plugin"
	if test ! -e plugins; then mkdir plugins; fi
	PLUGINS="`cat plug`"
	echo "XMLLibrarian;$PLUGINS" > plug2
	mv -f plug2 plug
	if test ! -e offline
	then
		java $JOPTS -jar bin/sha1test.jar plugins/XMLLibrarian.jar plugins >/dev/null 2>&1
	fi
	rm -f xmllibrarian
fi
