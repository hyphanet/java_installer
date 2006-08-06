#!/bin/bash

DST="$INSTALL_PATH"

echo "install: $INSTALL_PATH"
cd "$DST"
if [[ -e stun ]]
then
	echo "Enabling the STUN plugin"
	echo "pluginmanager.loadplugin=*@file://$INSTALL_PATH/plugins/JSTUN.jar;" >> freenet.ini
	rm -f stun
fi
if [[ -e update ]]
then
	echo "Enabling the auto-update feature"
	echo "node.updater.autoupdate=true" >> freenet.ini
	rm -f update
fi

chmod a+rx -R $INSTALL_PATH/bin $INSTALL_PATH/lib

echo "Downloading freenet-stable-latest.jar"
java -jar bin/sha1test.jar freenet-stable-latest.jar "$DST" || exit 1
echo "Downloading freenet-ext.jar"
java -jar bin/sha1test.jar freenet-ext.jar "$DST" || exit 1
echo "Downloading update.sh"
java -jar bin/sha1test.jar update/update.sh "$DST" || exit 1
chmod +x $DST/update.sh
./run.sh start
echo "Waiting for Freenet to startup"
sleep 10
echo "Starting up a browser"
java -cp bin/browser.jar BareBonesBrowserLaunch "http://127.0.0.1:8888/"
java -cp bin/browser.jar BareBonesBrowserLaunch "http://$INSTALL_PATH/welcome.html"

echo "Finished"

exit 0
