#!/bin/sh

. "$HOME/_install_toSource.sh" || exit 0
cd "$INSTALL_PATH"

echo "Detecting tcp-ports availability..."
# Try to auto-detect the first available port for fproxy
FPROXY_PORT=8888
java $JOPTS -jar bin/bindtest.jar $FPROXY_PORT 2>&1 >/dev/null
if test $? -ne 0
then
	FPROXY_PORT=8889
	echo "Can not bind fproxy to 8888: let's try $FPROXY_PORT instead."
	java $JOPTS -jar bin/bindtest.jar $FPROXY_PORT
	if test $? -ne 0
	then
		FPROXY_PORT=9999
		java -jar bin/bindtest.jar $FPROXY_PORT
		if test $? -ne 0
		then
			echo "Can not bind any socket on 127.0.0.1:"
			echo "		IT SHOULDN'T HAPPEN\!"
			echo ""
			echo "Make sure your loopback interface is properly configured. Delete Freenet\'s directory and retry."
			touch .isInstalled
			exit 1
		fi
	fi

	cat bin/browse.sh | sed "s/8888/$FPROXY_PORT/g" > browse.sh
	mv browse.sh bin/browse.sh

	cat bin/install_autostart.sh | sed "s/8888/$FPROXY_PORT/g" > install_autostart.sh
	mv install_autostart.sh bin/install_autostart.sh

	cat bin/remove_cronjob.sh | sed "s/8888/$FPROXY_PORT/g" > remove_cronjob.sh
	mv remove_cronjob.sh bin/remove_cronjob.sh

	chmod u+rx bin/*sh

fi
echo "fproxy.enabled=true" >> freenet.ini
echo "fproxy.port=$FPROXY_PORT" >> freenet.ini
echo "node.l10n=$ISO3_LANG" >> freenet.ini
echo "fproxy.enableHistoryCloaking=true" >> freenet.ini

# Translate if needed
FILE="dont-close-me.html"
if test -f dont-close-me.$ISO3_LANG.html
then
	FILE="dont-close-me.$ISO3_LANG.html"
fi
cat "$FILE" | sed "s/8888/$FPROXY_PORT/g" >_dont-close-me.html
rm -f dont-close-me.*html
mv _dont-close-me.html dont-close-me.html

# Try to auto-detect the first available port for fcp
FCP_PORT=9481
java $JOPTS -jar bin/bindtest.jar $FCP_PORT 2>&1 >/dev/null
if test $? -ne 0
then
	FCP_PORT=9482
	echo "Can not bind fcp to 9481: force it to $FCP_PORT instead."
fi
echo "fcp.enabled=true" >> freenet.ini
echo "fcp.port=$FCP_PORT" >> freenet.ini

# Swallow output to avoid major problems if the installer exits before the script does (it should, but doesn't usually if you enable desktop icons).
sh ./bin/browse.sh "http://127.0.0.1:$FPROXY_PORT/wizard/" > /dev/null &
