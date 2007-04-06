#!/bin/sh

INSTALL_PATH="${INSTALL_PATH:-$PWD}"

cd "$INSTALL_PATH"

# Starting the node up
./run.sh start

echo "Starting up a browser"
java -cp bin/browser.jar BareBonesBrowserLaunch "file://$INSTALL_PATH/welcome.html"

echo "Finished"

exit 0
