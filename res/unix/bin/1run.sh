#!/bin/sh

. "$HOME/_install_toSource.sh"
cd "$INSTALL_PATH"

echo "fproxy.enablePersistentConnections=true" >> freenet.ini
echo End >> freenet.ini

# Starting the node up
./run.sh start

echo "Starting up a browser"
./bin/browse.sh "file://$INSTALL_PATH/welcome.html"
