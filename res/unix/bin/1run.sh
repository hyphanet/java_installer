#!/bin/bash

DST="$INSTALL_PATH"

echo "install: $INSTALL_PATH"
cd "$DST"

# Tweak freenet.ini before the first startup
if [[ -e stun ]]
then
	./bin/install_jstun.sh
	echo "Enabling the STUN plugin"
	echo "pluginmanager.loadplugin=plugins.JSTUN@file://$INSTALL_PATH/plugins/JSTUN.jar;" >> freenet.ini
	rm -f stun
fi
if [[ -e update ]]
then
	echo "Enabling the auto-update feature"
	echo "node.updater.autoupdate=true" >> freenet.ini
	rm -f update
fi

# Try to auto-detect the first aviable port for fproxy
FPROXY_PORT=8888
java -jar bin/bindtest.jar $FPROXY_PORT
if [[ $? -ne 0 ]]
then
	FPROXY_PORT=8889
	echo "Can not bind fproxy to 8888: let's try $FPROXY_PORT insteed."
	java -jar bin/bindtest.jar $FPROXY_PORT
	if [[ $? -ne 0 ]]
	then
		FPROXY_PORT=9999
		echo "Can not bind fproxy to 8889: force it to $FPROXY_PORT insteed. You might have to edit freenet.ini by hand yourself to choose an aviable, bindable tcp port."
	fi
fi
echo -e "fproxy.enabled=true\nfproxy.port=$FPROXY_PORT" >> freenet.ini

# Try to auto-detect the first aviable port for fcp
FCP_PORT=9481
java -jar bin/bindtest.jar $FCP_PORT
if [[ $? -ne 0 ]]
then
	FCP_PORT=9482
	echo "Can not bind fcp to 9481: force it to $FCP_PORT insteed. You might have to edit freenet.ini by hand yourself to choose an aviable, bindable tcp port."
fi
echo -e "fcp.enabled=true\nfcp.port=$FCP_PORT" >> freenet.ini

# Try to auto-detect the first aviable port for console
CONSOLE_PORT=2323
java -jar bin/bindtest.jar $CONSOLE_PORT
if [[ $? -ne 0 ]]
then
	CONSOLE_PORT=2324
	echo "Can not bind console to 2323: force it to $CONSOLE_PORT insteed. You might have to edit freenet.ini by hand yourself to choose an aviable, bindable tcp port."
fi
echo -e "console.enabled=true\nconsole.port=$CONSOLE_PORT" >> freenet.ini

# We need the exec flag on /bin
chmod a+rx -R $INSTALL_PATH/bin $INSTALL_PATH/lib

echo "Downloading freenet-stable-latest.jar"
java -jar bin/sha1test.jar freenet-stable-latest.jar "$DST" || exit 1
ln -s freenet-stable-latest.jar freenet.jar
echo "Downloading freenet-ext.jar"
java -jar bin/sha1test.jar freenet-ext.jar "$DST" || exit 1
echo "Downloading update.sh"
java -jar bin/sha1test.jar update/update.sh "$DST" || exit 1
chmod +x $DST/update.sh

# Starting the node up
./run.sh start
echo "Waiting for Freenet to startup"
sleep 10
echo "Starting up a browser"
java -cp bin/browser.jar BareBonesBrowserLaunch "http://127.0.0.1:$FPROXY_PORT/"
java -cp bin/browser.jar BareBonesBrowserLaunch "file:///$INSTALL_PATH/welcome.html"

echo "Finished"

exit 0
