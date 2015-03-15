#!/bin/sh

cd "$INSTALL_PATH"
POSSIBLE_NAMES="iceweasel firefox mozilla mozilla-firefox"

if test $# -lt 1
then
	URL="http://127.0.0.1:8888"
else
	URL="$1"
fi

# Wait until the installer has finished
while test ! -f Uninstaller/install.log
do
	sleep 1
done

startFreenet() {
	./run.sh start
	sleep 5
}

PID=
if test -e Freenet.pid
then
	PID=`cat Freenet.pid`
	# This might still fail in the real-world but should cover most cases
	if ! kill -0 $PID 2>/dev/null
	then
		startFreenet
	fi
else
	startFreenet
fi

java -Djava.net.preferIPv4Stack=true -cp bin/browser.jar BareBonesBrowserLaunch "$URL" &
