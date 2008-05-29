#!/bin/sh

. "$HOME/_install_toSource.sh"|| exit 0
cd "$INSTALL_PATH"

echo "fproxy.enablePersistentConnections=true" >> freenet.ini
echo End >> freenet.ini

# Starting the node up
echo "Starting Freenet 0.7..."
nohup sh ./run.sh start 2>&1 >wrapper.log &

echo "Starting up a browser"
sh ./bin/browse.sh "file://$INSTALL_PATH/welcome.html"
