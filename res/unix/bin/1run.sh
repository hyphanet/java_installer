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
echo "Downloading freenet-cvs-snapshot.jar"
java -jar bin/sha1test.jar freenet-cvs-snapshot.jar "$DST" || exit 1
echo "Downloading freenet-ext.jar"
java -jar bin/sha1test.jar freenet-ext.jar "$DST" || exit 1
./run.sh start
echo "Waiting for Freenet to startup"
sleep 10
echo "Starting up a browser"
java -cp bin/browser.jar BareBonesBrowserLaunch "http://127.0.0.1:8888/"
java -cp bin/browser.jar BareBonesBrowserLaunch "http://$INSTALL_PATH/welcome.html"

echo "Finished"

exit 0
