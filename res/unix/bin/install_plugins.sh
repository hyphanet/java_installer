#!/bin/bash

cd "$INSTALL_PATH"
source _install_toSource.sh

if test -e plug
then
	# Register plugins
	echo "pluginmanager.loadplugin=`cat plug`" >> freenet.ini

	# Cleanup
	rm -f plug plug2
fi
