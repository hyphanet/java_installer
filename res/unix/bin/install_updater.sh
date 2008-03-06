#!/bin/sh

cd "$INSTALL_PATH"
source _install_toSource.sh

# Tweak freenet.ini before the first startup
echo "node.updater.enabled=true" > freenet.ini
if test -e update
then
	echo "Enabling the auto-update feature"
	echo "node.updater.autoupdate=true" >> freenet.ini
	rm -f update
fi

if test ! -e offline
then
	echo "Downloading update.sh"
	java $JOPTS -jar bin/sha1test.jar update/update.sh >/dev/null 2>&1 || exit 1
fi

if test -e update.sh
then
	chmod a+rx update.sh
fi
