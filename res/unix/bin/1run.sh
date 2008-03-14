#!/bin/sh

INSTALL_PATH="${INSTALL_PATH:-$PWD}"

cd "$INSTALL_PATH"

echo End >> freenet.ini

# Starting the node up
./run.sh start

echo "Starting up a browser"
if test -e welcome.$ISO3_LANG.html
then
	HTMLFILE="file://$INSTALL_PATH/welcome.$ISO3_LANG.html"
else
	HTMLFILE="file://$INSTALL_PATH/welcome.html"
fi

./bin/browse.sh "$HTMLFILE"
