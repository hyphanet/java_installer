#!/bin/sh

. "$HOME/_install_toSource.sh" || exit 0
cd "$INSTALL_PATH"

if test -e plug
then
	# Register plugins
	echo "pluginmanager.loadplugin=`cat plug`" >> freenet.ini

	# Cleanup
	rm -f plug plug2
fi
