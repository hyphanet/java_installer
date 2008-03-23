#!/bin/sh

. "$HOME/_install_toSource.sh"
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
