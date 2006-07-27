#!/bin/bash
cd $INSTALL_PATH/bin
echo "Downloading JSTUN"
mkdir ../plugins
java -jar sha1test.jar JSTUN.jar ../plugins || exit 1
echo "Done"
