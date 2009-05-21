#!/bin/sh

. "$HOME/_install_toSource.sh" || exit 0
cd "$INSTALL_PATH"

	# Register plugins
	echo "pluginmanager.loadplugin=XMLLibrarian;KeyExplorer;ThawIndexBrowser" >> freenet.ini

	# Cleanup
	rm -f plug plug2
