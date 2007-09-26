#!/bin/sh

INSTALL_PATH="${INSTALL_PATH:-$PWD}"

cd "$INSTALL_PATH"

echo "Detecting tcp-ports availability..."
# Try to auto-detect the first available port for fproxy
FPROXY_PORT=8888
java -jar bin/bindtest.jar $FPROXY_PORT 2>&1 >/dev/null
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
echo -e "fproxy.enabled=true\nfproxy.port=$FPROXY_PORT" >> freenet.ini

# Try to auto-detect the first available port for fcp
FCP_PORT=9481
java -jar bin/bindtest.jar $FCP_PORT
if test $? -ne 0
then
	FCP_PORT=9482
	echo "Can not bind fcp to 9481: force it to $FCP_PORT instead."
fi
echo -e "fcp.enabled=true\nfcp.port=$FCP_PORT" >> freenet.ini

# Try to auto-detect the first available port for console
CONSOLE_PORT=2323
java -jar bin/bindtest.jar $CONSOLE_PORT
if test $? -ne 0
then
	CONSOLE_PORT=2324
	echo "Can not bind console to 2323: force it to $CONSOLE_PORT instead."
fi
echo -e "console.enabled=true\nconsole.port=$CONSOLE_PORT" >> freenet.ini
