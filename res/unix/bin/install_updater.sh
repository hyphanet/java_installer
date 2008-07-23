#!/bin/sh

. "$HOME/_install_toSource.sh" || exit 0
cd "$INSTALL_PATH"

# Tweak freenet.ini before the first startup
echo "node.updater.enabled=true" > freenet.ini
if test -f update
then
	echo "Enabling the auto-update feature"
	echo "node.updater.autoupdate=true" >> freenet.ini
	rm -f update
fi

if test ! -f offline
then
	echo "Downloading update.sh"
	java $JOPTS -jar bin/sha1test.jar update.sh ./ "$CAFILE" >/dev/null 2>&1 || exit 1
fi

if test -f update.sh
then
	chmod a+rx update.sh
fi
