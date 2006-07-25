#!/bin/bash
cd $INSTALL_PATH/bin
echo "Downloading jSite"
java -jar sha1test.jar jSite/jSite.jar ../ || exit 1
echo "Done"
