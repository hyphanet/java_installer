#!/bin/sh

if test ! -s bin/1run.sh
then
	echo 'This script should be started using ./bin/1run.sh!'
	exit
fi

if test -s freenet.ini
then
	echo "This script isn\'t meant to be used more than once."
	rm -f bin/1run.sh
	exit
fi

CAFILE="startssl.pem"

# We need the exec flag on /bin
chmod a+rx bin/* lib/* &>/dev/null

# Tweak freenet.ini before the first startup
echo "node.updater.enabled=true" > freenet.ini
echo "Enabling the auto-update feature"
echo "node.updater.autoupdate=true" >> freenet.ini

# Register plugins
echo "pluginmanager.loadplugin=JSTUN;UPnP" >> freenet.ini

echo "Detecting tcp-ports availability..."
# Try to auto-detect the first available port for fproxy
FPROXY_PORT=8888
java -jar bin/bindtest.jar $FPROXY_PORT &>/dev/null
if test $? -ne 0
then
	FPROXY_PORT=8889
	echo "Can not bind fproxy to 8888: let's try $FPROXY_PORT instead."
	java -jar bin/bindtest.jar $FPROXY_PORT
	if test $? -ne 0
	then
		FPROXY_PORT=9999
		echo "Can not bind fproxy to 8889: force it to $FPROXY_PORT instead."
	fi
	cat welcome.html | sed "s/8888/$FPROXY_PORT/g" >welcome2.html
	mv welcome2.html welcome.html
fi
echo "fproxy.enabled=true" >> freenet.ini
echo "fproxy.port=$FPROXY_PORT" >> freenet.ini

# Try to auto-detect the first available port for fcp
FCP_PORT=9481
java -jar bin/bindtest.jar $FCP_PORT
if test $? -ne 0
then
	FCP_PORT=9482
	echo "Can not bind fcp to 9481: force it to $FCP_PORT instead."
fi
echo "fcp.enabled=true" >> freenet.ini
echo "fcp.port=$FCP_PORT" >> freenet.ini

echo "Downloading freenet-stable-latest.jar"
java -jar bin/sha1test.jar freenet-stable-latest.jar "." $CAFILE >/dev/null || exit 1 
ln -s freenet-stable-latest.jar freenet.jar
echo "Downloading freenet-ext.jar"
java -jar bin/sha1test.jar freenet-ext.jar "." $CAFILE >/dev/null || exit 1
echo "Downloading update.sh"
java -jar bin/sha1test.jar update.sh "." $CAFILE >/dev/null || exit 1
chmod a+rx "./update.sh"
echo "Downloading seednodes.fref"
java -jar bin/sha1test.jar seednodes.fref "." $CAFILE >/dev/null || exit 1

# Starting the node up
./run.sh start

echo "Please visit file://$PWD/welcome.html to configure your node"
echo "Finished"

rm -f bin/1run.sh
touch .isInstalled
exit 0
