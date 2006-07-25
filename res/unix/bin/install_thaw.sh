#!/bin/bash
cd $INSTALL_PATH/bin
echo "Downloading Thaw"
java -jar sha1test.jar Thaw/Thaw.jar ../ || exit 1
echo "Done"
