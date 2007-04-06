#!/bin/bash

INSTALL_PATH="${INSTALL_PATH:-$PWD}"

cd "$INSTALL_PATH"

echo "Downloading freenet-stable-latest.jar"
java -jar bin/sha1test.jar freenet-stable-latest.jar "$INSTALL_PATH" &>/dev/null || exit 1 
ln -s freenet-stable-latest.jar freenet.jar
