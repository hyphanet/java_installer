#!/bin/sh

INSTALL_PATH="${INSTALL_PATH:-$PWD}"

cd "$INSTALL_PATH"
if test -s freenet-ext.jar
then
	echo "This script isn't meant to be used more than once."
	exit
fi

# We need the exec flag on /bin
chmod a+rx bin/* lib/* &>/dev/null

# Tweak freenet.ini before the first startup
PLUGINS=""
if test -e stun
then
	echo "Enabling the STUN plugin"
	mkdir plugins &>/dev/null
	PLUGINS="plugins.JSTUN.JSTUN@file://$INSTALL_PATH/plugins/JSTUN.jar;$PLUGINS"
	java -jar bin/sha1test.jar plugins/JSTUN.jar.url plugins &>/dev/null
	mv plugins/JSTUN.jar.url plugins/JSTUN.jar
	rm -f plugins/JSTUN.jar.url
	rm -f stun
fi

if test -e librarian
then
	echo "Enabling the Librarian plugin"
	mkdir plugins &>/dev/null
	PLUGINS="plugins.Librarian.Librarian@file://$INSTALL_PATH/plugins/Librarian.jar;$PLUGINS"
	java -jar bin/sha1test.jar plugins/Librarian.jar.url plugins &>/dev/null
	mv plugins/Librarian.jar.url plugins/Librarian.jar
	rm -f plugins/Librarian.jar.url
	rm -f librarian
fi

# Register plugins
echo "pluginmanager.loadplugin=$PLUGINS" >> freenet.ini

if test -e update
then
	echo "Enabling the auto-update feature"
	echo "node.updater.autoupdate=true" >> freenet.ini
	rm -f update
fi

echo "Detecting tcp-ports availability..."
# Try to auto-detect the first available port for fproxy
FPROXY_PORT=8888
java -jar bin/bindtest.jar $FPROXY_PORT &>/dev/null
if test $? -ne 0
then
	FPROXY_PORT=8889
	echo "Can not bind fproxy to 8888: let's try $FPROXY_PORT insteed."
	java -jar bin/bindtest.jar $FPROXY_PORT
	if test $? -ne 0
	then
		FPROXY_PORT=9999
		echo "Can not bind fproxy to 8889: force it to $FPROXY_PORT insteed."
	fi
	cat welcome.html | sed "s/8888/$FPROXY_PORT/g" >welcome2.html
	mv welcome2.html welcome.html
fi
echo -e "fproxy.enabled=true\nfproxy.port=$FPROXY_PORT" >> freenet.ini

# Try to auto-detect the first available port for fcp
FCP_PORT=9481
java -jar bin/bindtest.jar $FCP_PORT
if test $? -ne 0
then
	FCP_PORT=9482
	echo "Can not bind fcp to 9481: force it to $FCP_PORT insteed."
fi
echo -e "fcp.enabled=true\nfcp.port=$FCP_PORT" >> freenet.ini

# Try to auto-detect the first available port for console
CONSOLE_PORT=2323
java -jar bin/bindtest.jar $CONSOLE_PORT
if test $? -ne 0
then
	CONSOLE_PORT=2324
	echo "Can not bind console to 2323: force it to $CONSOLE_PORT insteed."
fi
echo -e "console.enabled=true\nconsole.port=$CONSOLE_PORT" >> freenet.ini

echo "Downloading freenet-stable-latest.jar"
java -jar bin/sha1test.jar freenet-stable-latest.jar "$INSTALL_PATH" &>/dev/null || exit 1 
ln -s freenet-stable-latest.jar freenet.jar
echo "Downloading freenet-ext.jar"
java -jar bin/sha1test.jar freenet-ext.jar "$INSTALL_PATH" &>/dev/null || exit 1
echo "Downloading update.sh"
java -jar bin/sha1test.jar update/update.sh "$INSTALL_PATH" &>/dev/null || exit 1
chmod a+rx "$INSTALL_PATH/update.sh"

# Starting the node up
./run.sh start

if test -e thaw
then
	rm -f thaw
	echo "Downloading Thaw"
	java -jar bin/sha1test.jar Thaw/Thaw.jar ./ &>/dev/null || exit 1
fi

if test -e jsite
then
	rm -f jsite
	echo "Downloading jSite"
	java -jar bin/sha1test.jar jSite/jSite.jar ./ &>/dev/null || exit 1
fi

if test -e frost
then
	rm -f frost
	echo "Downloading frost"
	java -jar bin/sha1test.jar frost/frost.zip ./ &>/dev/null || exit 1
	echo "Unzipping frost"
	mkdir frost
	java -jar bin/uncompress.jar frost.zip frost &>/dev/null
fi

echo "Starting up a browser"
java -cp bin/browser.jar BareBonesBrowserLaunch "http://127.0.0.1:$FPROXY_PORT/"
java -cp bin/browser.jar BareBonesBrowserLaunch "file://$INSTALL_PATH/welcome.html"

echo "Finished"

exit 0
