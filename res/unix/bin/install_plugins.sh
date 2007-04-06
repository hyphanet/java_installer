#!/bin/bash

INSTALL_PATH="${INSTALL_PATH:-$PWD}"

cd "$INSTALL_PATH"

# Register plugins
echo "pluginmanager.loadplugin=`cat plug`" >> freenet.ini

# Cleanup
rm -f plug plug2
