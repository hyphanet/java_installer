#!/bin/bash

DST="$INSTALL_PATH"

echo "install: $INSTALL_PATH"
cd "$DST"
echo "Downloading freenet-cvs-snapshot.jar"
java -jar bin/sha1test.jar freenet-cvs-snapshot.jar "$DST" || exit 1
echo "Downloading freenet-ext.jar"
java -jar bin/sha1test.jar freenet-ext.jar "$DST" || exit 1
./run.sh start
echo "Waiting for Freenet to startup"
sleep 10
echo "Starting up a browser"
java -cp bin/browser.jar BareBonesBrowserLaunch "http://127.0.0.1:8888/"

echo "Finished"

exit 0
