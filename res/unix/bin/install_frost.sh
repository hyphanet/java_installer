#!/bin/bash
cd $INSTALL_PATH/bin
echo "Downloading frost"
java -jar sha1test.jar frost/frost.zip ../ || exit 1
echo "Unzipping frost"
mkdir ../frost
java -jar uncompress.jar ../frost.zip ../frost
echo "Done"
