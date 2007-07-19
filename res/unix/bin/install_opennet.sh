#!/bin/bash

INSTALL_PATH="${INSTALL_PATH:-$PWD}"

cd "$INSTALL_PATH"

if test -e opennet
then
	# Register opennet
	echo "Enabling Opennet"
	echo "node.opennet.enabled=true" >> freenet.ini

	# Cleanup
	rm -f opennet
fi
